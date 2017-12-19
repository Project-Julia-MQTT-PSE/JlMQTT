include("../MqttClient.jl")
include("../MqttNetworkChannel.jl")
include("FindContextPackage.jl")
include("../Messages/Definitions.jl")
include("../Messages/MqttMsgPubcomp.jl")
include("../Messages/MqttMsgPublish.jl")
include("../Messages/MqttMsgPuback.jl")
include("../Messages/MqttMsgPubrec.jl")
include("../Messages/MqttMsgPubrel.jl")
include("../Messages/MqttMsgContext.jl")
include("../Messages/MqttMsgSuback.jl")
include("../Messages/MqttMsgUnsuback.jl")

#Process ReceivedMessage depending on Type and QoS Level
#No return value
function ProcessReceivedMessage(msg, client::MqttClient)
  #If PUBLISH Message
  if (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(PUBLISH_TYPE)
    #Check QoS Level
    #on Level zero introduce into callback channel
    if msg.msgBase.qos == AT_MOST_ONCE
      put!(client.subscribedTopicMsgChannel, ReveivedMessage(msg.topic, convert(String, msg.message)))
    #on Level one Send PUBACK and introduce into callback channel
    elseif msg.msgBase.qos == AT_LEAST_ONCE
      response::MqttMsgPuback = MqttMsgPuback(MqttMsgBase(PUBACK_TYPE, msg.msgBase.msgId))
      Write(client.channel, Serialize(response))
      put!(client.subscribedTopicMsgChannel, ReceivedMessage(msg.topic, convert(String, msg.message)))
    #on Level two, save in queue and send PUBREC
    elseif msg.msgBase.qos == EXACTLY_ONCE
      #If this PUBLISH isnt in the contextMsgChannel,
      #it means that this is the first one, send PUBREC and enque into contextMsgChannel
      #Enque it into contextMsgChannel, if exist re-send PUBREC
      msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
      if msgContext == 0
        put!(client.contextMsgChannel, MqttMsgContext(msg, WaitForPubrel, ToAcknowledge))
      else
        put!(client.contextMsgChannel, msgContext)
      end
        Write(client.channel, Serialize(MqttMsgPubrec(MqttMsgBase(PUBREC_TYPE, msg.msgBase.msgId))))
    end
  #If PUBREL Message
  elseif (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(PUBREL_TYPE)
    #If corresponding PUBLISH isn't in the contextMsgChannel queue, it means it was alreadyprocessed
    #and PUBREL was already received and we send PUBCOMP, but PUBCOMB didn't reached Broker
    #Only re-send PUBCOMP
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
    if msgContext != 0
      put!(client.subscribedTopicMsgChannel, ReceivedMessage(msgContext.message.topic, convert(String, msgContext.message.message)))
    end
    Write(client.channel, Serialize(MqttMsgPubcomp(MqttMsgBase(PUBCOMP_TYPE, msg.msgBase.msgId))))
  #If PUBREC Message
  elseif (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(PUBREC_TYPE)
    #if corresponding PUBLISH isn't in the contextMsgChannel queue, it means
    #that we sent PUBLISH several times but broker didn't send PUBREC in times
    #the publish is failed and we only need to ignore this PUBREX
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToPublish)
    #If found update context and put back into the channel
    #Send PUBREL
    if msgContext != 0
      msgContext.state = WaitForPubcomp
      put!(client.contextMsgChannel, msgContext)
    end
    msg = MqttMsgPubrel(MqttMsgBase(PUBREL_TYPE, msg.msgBase.msgId))
    Write(client.channel, Serialize(msg))
  #If PUBCOM Message
  elseif (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(PUBCOMP_TYPE)
    #if corresponding PUBLISH isn't in the contextMsgChannel queue, it means
    #We sent PUBLISH message, sent PUBREL (after receiving PUBREC)
    #and alread received PUBCOMP, but publisher didn't receive PUBREL so it re-sent PUBCOMP. We onlc ignore this PUBCOMP
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToPublish)
  #If SUBACK Message
  elseif (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(SUBACK_TYPE)
    #If corresponding SUBSCRIBE isnt in the contextMsgChannel, it means
    #We already received a SUBACK message, and it can be ignored
    #If present we can delete the SUBSCRIBE package from the queue
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
  #If UNSUBACK Message
  elseif (msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET) == UInt8(UNSUBACK_TYPE)
    #If corresponding UNSUBSCRIBE isnt in the contextMsgChannel, it means
    #We already received a UNSUBACK message, and it can be ignored
    #If present we can delete the UNSUBSCRIBE package from the queue
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
  end
end
