include("../MqttClient.jl")
include("../MqttNetworkChannel.jl")
include("ProcessReceivedMessage.jl")
include("../Messages/Definitions.jl")
include("../Messages/MqttMsgPingreq.jl")
include("../Messages/MqttMsgPingresp.jl")
include("../Messages/MqttMsgConnack.jl")
include("../Messages/MqttMsgPubcomp.jl")
include("../Messages/MqttMsgPublish.jl")
include("../Messages/MqttMsgPuback.jl")
include("../Messages/MqttMsgPubrec.jl")
include("../Messages/MqttMsgPubrel.jl")
include("../Messages/MqttMsgContext.jl")
include("../Messages/MqttMsgSubscribe.jl")
include("../Messages/MqttMsgSuback.jl")
include("../Messages/MqttMsgUnsubscribe.jl")
include("../Messages/MqttMsgUnsuback.jl")


# Keep Alive thread, shuts down threads when timeout occurs
#No return value
function KeepAliveThread(client::MqttClient)
  while client.isRunning
    ping::MqttMsgPingreq = MqttMsgPingreqConstructor()

    Write(client.channel, Serialize(ping))
    while true
      if client.lastCommTime < client.keepAlivePeriod
        if isready(client.sendReceiveChannel)
          msgReceived = take!(client.sendReceiveChannel)
          client.lastCommTime = 0
          break
        end
      else
        client.isRunning = false
       close(client.contextMsgChannel)
       close(client.sendReceiveChannel)
       close(client.subscribedTopicMsgChannel)
        break
      end
      client.lastCommTime += 100
      sleep(1)
    end
    sleep(10)
  end
end

#Async Task which waits for incoming message
#Parse them together, or throw error for wrong message
#No return value
function ReceiveThread(client::MqttClient)
  readBytes::Int = 0
  fixedHeaderFirstByte = UInt8[0x00]
  msgType::UInt8 = 0x00

  while client.isRunning
    readBytes = Read(client.channel, fixedHeaderFirstByte)
    if readBytes > 0x00
      msgtype = MsgType(UInt8((fixedHeaderFirstByte[1] & MSG_TYPE_MASK) >> MSG_TYPE_OFFSET))
      if msgtype == CONNACK_TYPE
        put!(client.sendReceiveChannel, MsgConnackParse(client.channel))
      elseif msgtype == PINGRESP_TYPE
        put!((client.sendReceiveChannel), MsgPingrespParse(client.channel))
      elseif msgtype == SUBACK_TYPE
        ProcessReceivedMessage(MsgSubackParse(client.channel), client)
      elseif msgtype == PUBLISH_TYPE
        ProcessReceivedMessage(MsgPublishParse(client.channel, fixedHeaderFirstByte[1]), client)
      elseif msgtype == PUBACK_TYPE
        ProcessReceivedMessage(MsgPubackParse(client.channel), client)
      elseif msgtype == PUBREC_TYPE
        ProcessReceivedMessage(MsgPubrecParse(client.channel), client)
      elseif msgtype == PUBREL_TYPE
        ProcessReceivedMessage(MsgPubrelParse(client.channel), client)
      elseif msgtype == PUBCOMP_TYPE
        ProcessReceivedMessage(MsgPubackParse(client.channel), client)
      elseif msgtype == UNSUBACK_TYPE
        ProcessReceivedMessage(MsgUnsubackParse(client.channel), client)
      else
        throw(ErrorException("WRONG BROKER MESSAGE! (NOT SUPPORTED PACKAGE)"))
      end
    end
  end
end

#Loop through the Context Package Channel and check for potential resends or deletes
#No Return value
function KeepAliveContextChannelThread(client::MqttClient)
  while client.isRunning
    lock(client.contextQueueLock)
    count::Int = length(client.contextMsgChannel.data)
    while count != 0
      tmp::MqttMsgContext = take!(client.contextMsgChannel)
      #If package has reached timeout and has available retries, re-send and requery into queue
      if tmp.timestamp >= MQTT_DEFAULT_CONTEXT_TIMEOUT && tmp.attempt <= MQTT_DEFAULT_CONTEXT_RETRY
        if MsgType(tmp.message.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == PUBLISH_TYPE && tmp.state == WaitForPubrec
          #Set DUP = 1 for retry
          tmp.message.msgBase.fixedHeader =  tmp.message.msgBase.fixedHeader | 0x04
        end
        Write(client.channel, Serialize(tmp.message))
        tmp.attempt += 1
        tmp.timestamp = 1
        put!(client.contextMsgChannel, tmp)
      #If package timeout isnt reached and retries available, requery into queue
      elseif tmp.timestamp < MQTT_DEFAULT_CONTEXT_TIMEOUT && tmp.attempt < MQTT_DEFAULT_CONTEXT_RETRY
        tmp.timestamp += 1000
        put!(client.contextMsgChannel, tmp)
      end
      count -= 1
    end
    unlock(client.contextQueueLock)
    sleep(1)
  end
end
