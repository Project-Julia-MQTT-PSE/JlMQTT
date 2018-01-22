include("../MqttClient.jl")
include("../MqttNetworkChannel.jl")
include("../ReceivedMessage.jl")
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

  givenMsgType = MsgType(msg.msgBase.fixedHeader >> MSG_TYPE_OFFSET)

  if givenMsgType == PUBLISH_TYPE
    qos = QosLevel(UInt8((msg.msgBase.fixedHeader & QOS_LEVEL_MASK) >> QOS_LEVEL_OFFSET))
    if qos == AT_MOST_ONCE
      put!(client.subscribedTopicMsgChannel, ReceivedMessage(msg.topic, convert(String, msg.message)))
    elseif qos == AT_LEAST_ONCE
      Write(client.channel, Serialize(MqttMsgPubackConstructor(MqttMsgBase(PUBACK_TYPE, msg.msgBase.msgId))))
      put!(client.subscribedTopicMsgChannel, ReceivedMessage(msg.topic, convert(String, msg.message)))
    elseif qos == EXACTLY_ONCE
      msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
      if msgContext == 0
        put!(client.contextMsgChannel, MqttMsgContextConstructor(msg, WaitForPubrel, ToAcknowledge))
      else
        put!(client.contextMsgChannel, msgContext)
      end
        Write(client.channel, Serialize(MqttMsgPubrecConstructor(MqttMsgBase(PUBREC_TYPE, msg.msgBase.msgId))))
    end
  elseif givenMsgType == PUBREL_TYPE
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
    if msgContext != 0
      put!(client.subscribedTopicMsgChannel, ReceivedMessage(msgContext.message.topic, convert(String, msgContext.message.message)))
    end
    Write(client.channel, Serialize(MqttMsgPubcompConstructor(MqttMsgBase(PUBCOMP_TYPE, msg.msgBase.msgId))))
  elseif givenMsgType == PUBREC_TYPE
    msgContext = FindContextPackage(client, msg.msgBase.msgId, ToPublish)
    if msgContext != 0
      msgContext.state = WaitForPubcomp
      put!(client.contextMsgChannel, msgContext)
    end
    Write(client.channel, Serialize(MqttMsgPubrelConstructor(MqttMsgBase(PUBREL_TYPE, msg.msgBase.msgId, retain=false, dup=false, qos=AT_LEAST_ONCE))))
  elseif any(givenMsgType .== (PUBCOMP_TYPE, PUBACK_TYPE))
    FindContextPackage(client, msg.msgBase.msgId, ToPublish)
  elseif any(givenMsgType .== (SUBACK_TYPE, UNSUBACK_TYPE))
    FindContextPackage(client, msg.msgBase.msgId, ToAcknowledge)
  end
end
