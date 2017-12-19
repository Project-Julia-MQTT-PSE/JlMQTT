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
  @async while client.isRunning
    ping::MqttMsgPingreq = MqttMsgPingreq()

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
        break
      end
      client.lastCommTime += 1000
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

  @async while client.isRunning
    readBytes = Read(client.channel, fixedHeaderFirstByte)
    if readBytes > 0x00
      msgType = ((fixedHeaderFirstByte[1] & MSG_TYPE_MASK) >> MSG_TYPE_OFFSET)::UInt8
      if MsgType == UInt8(CONNECT_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (CONNECT)"))
      elseif msgType == UInt8(CONNACK_TYPE)
        #println("CONNACK MESSAGE RECEIVED!")
        put!(client.sendReceiveChannel, MsgConnackParse(client.channel))
      elseif msgType == UInt8(PINGREQ_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (PINGREQ)"))
      elseif msgType == UInt8(PINGRESP_TYPE)
        #println("PINGRESP MESSAGE RECEIVED!")
        put!((client.sendReceiveChannel), MsgPingrespParse(client.channel))
      elseif msgType == UInt8(SUBSCRIBE_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (SUBSCRIBE)"))
      elseif msgType == UInt8(SUBACK_TYPE)
        #println("SUBACK MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgSubackParse(client.channel), client)
      elseif msgType == UInt8(PUBLISH_TYPE)
        #println("PUBLISH MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgPublishParse(client.channel, fixedHeaderFirstByte[1]), client)
      elseif msgType == UInt8(PUBACK_TYPE)
        #println("PUBACK MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgPubackParse(client.channel), client)
      elseif msgType == UInt8(PUBREC_TYPE)
        #println("PUBREC MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgPubrecParse(client.channel), client)
      elseif msgType == UInt8(PUBREL_TYPE)
        #println("PUBREL MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgPubrelParse(client.channel), client)
      elseif msgType == UInt8(PUBCOMP_TYPE)
        #println("PUBCOMP MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgPubackParse(client.channel), client)
      elseif msgType == UInt8(UNSUBSCRIBE_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (UNSUBSCRIBE)"))
      elseif msgType == UInt8(UNSUBACK_TYPE)
        #println("UNSUBACK MESSAGE RECEIVED!")
        ProcessReceivedMessage(MsgUnsubackParse(client.channel), client)
      elseif msgType == UInt8(DISCONNECT_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (DISCONNECT)"))
      else
        throw(ErrorException("WRONG BROKER MESSAGE! (UNKNOWN)"))
      end
    end
  end
end

#Loop through the Context Package Channel and check for potential resends or deletes
#No Return value
function KeepAliveContextChannelThread(client::MqttClient)
  @async while client.isRunning
    lock(client.contextQueueLock)
    count::Int = length(client.contextMsgChannel.data)
    while count != 0
      tmp::MqttMsgContext = take!(client.contextMsgChannel)
      #If package has reached timeout and has available reties, re-send and requery into queue
      if tmp.timestamp >= MQTT_DEFAULT_CONTEXT_TIMEOUT && tmp.attempt <= MQTT_DEFAULT_CONTEXT_RETRY
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
