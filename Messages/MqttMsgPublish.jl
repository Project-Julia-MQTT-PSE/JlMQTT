include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const QOS_LEVEL_MASK = 0x06

#=Represent a PUBLISH Package which can be send to the Broker

fixedHeader = the FixedHeader value

topic = topic to which the message will be published

message = to be published message

messageId = OPTIONAL, only required if QoS level is set to level 1 or 2, to identify a specific message

=#

#Structure generates a publish package which is sent to the broker.
#msgBase::MqttMsgBase' : Message base instance used in creation of package.
#topic::String' : The topic message is published to in string form.
#message:Vector{UInt8}' : The message itself that is published to the topic and will be sent to all subscribers

#Mqtt Publish Package
mutable struct MqttMsgPublish <: MqttPacket
  msgBase::MqttMsgBase
  topic::String
  message::Vector{UInt8}

  function MqttMsgPublish(
    topic::String;
    message::Vector{UInt8} = Vector{UInt8}(1),
    base = MqttMsgBase(PUBLISH_TYPE, UInt16(0), retain=false, dup=false, qos=AT_MOST_ONCE))
    return new(base, topic, message)
  end

end

#Serializes the publish message.
#Return Byte Array
function Serialize(msgPublish::MqttMsgPublish)
  fixedHeaderSize::Int = 0
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

  #Check that Topic contain no Wildcards
  in('#', msgPublish.topic) || in('+', msgPublish.topic) ? throw(ErrorException("Topic can't contain a Wildcard")) : 0x00
  #Check Topic Length
  (length(msgPublish.topic) < MIN_TOPIC_LENGTH || length(msgPublish.topic) > MAX_TOPIC_LENGTH) ? throw(ErrorException("Topic length exceeded")) : 0x00
  #Check if QoS Level is wrong
  if (msgPublish.msgBase.fixedHeader & QOS_LEVEL_MASK) == QOS_LEVEL_MASK
    throw(ErrorException("QoS is set to a wrong value"))
  end

  topicUtf8 = convert(Array{UInt8}, msgPublish.topic)

  #Topic Length 2 two for MSB & LSB
  varHeaderSize += length(topicUtf8) + 2

  #If Qos level is 1 or 2 add the Message ID LSB & MSB
  if (UInt8(msgPublish.msgBase.qos) == UInt8(EXACTLY_ONCE) || UInt8(msgPublish.msgBase.qos) == UInt8(AT_LEAST_ONCE))
    varHeaderSize += MESSAGE_ID_SIZE
  end

  if msgPublish.message != ""
    payloadSize += length(msgPublish.message)
  end

  remainingLength += (varHeaderSize + payloadSize)

  #building protocol package
  fixedHeaderSize = 1
  tmp::Int = remainingLength

      #Add Length to Fixed header depending on the remainging length
      while true
        fixedHeaderSize += 1
        tmp = round(tmp / 128)
        if !(tmp > 0)
          break
        end
      end

      msgPackage = Array{UInt8, 1}(fixedHeaderSize + varHeaderSize + payloadSize)

      msgPackage[index] = msgPublish.msgBase.fixedHeader
      index += 1

      #Encode remaining length part for fixed header
      index = encodeRemainingLength(remainingLength, msgPackage, index)

      #Move topic name to packageBuffer
      #First MSB byte
      msgPackage[index] = (endof(topicUtf8) >> 8) & 0x00FF
      index += 1
      #Second LSB byte
      msgPackage[index] = endof(topicUtf8) & 0x00FF
      index += 1

      copy!(msgPackage, index, topicUtf8, 1, length(topicUtf8))

      index += length(topicUtf8)

      #Set Message Id if QoS level is Set
      if (msgPublish.msgBase.qos == AT_LEAST_ONCE) || (msgPublish.msgBase.qos == EXACTLY_ONCE)
        #check if messageId isn't 0
        if msgPublish.msgBase.msgId == 0
          throw(ErrorException("Message Id can not be 0"))
        end
      #Message Id MSB
      msgPackage[index] = ((msgPublish.msgBase.msgId >> 8) & 0x00FF)
      index += 1
      #Message Id LSB
      msgPackage[index] = (msgPublish.msgBase.msgId & 0x00FF)
      index += 1
      end
      if msgPublish.message != ""
            copy!(msgPackage, index,  msgPublish.message, 1, length(msgPublish.message))
      end
      return msgPackage
end


# Deserialize MQTT message publish
#REturn a MqttMsgPub Packag
function MsgPublishParse(network::MqttNetworkChannel, fixedHeaderFirstByte::UInt8)
  index::Int = 1
  msg::MqttMsgPublish = MqttMsgPublish("")

  #Allocate Buffer
  remainingLength::Int = decodeRemainingLength(network)
  buffer = Vector{UInt8}(remainingLength)
  received = Read(network, buffer)

  #Topic name
  topicUtf8Length::Int = (buffer[index] << 8) & 0xFF00
  index += 1
  topicUtf8Length |= buffer[index]
  index += 1
  topicUtf8 = Vector{UInt8}(topicUtf8Length)
  copy!(topicUtf8, 1, buffer, index, topicUtf8Length)
  index += topicUtf8Length

  #Save topic
  msg.topic = topicUtf8
  #QoS level from fixed header
  msg.msgBase.qos = UInt8((fixedHeaderFirstByte &  QOS_LEVEL_MASK) >> QOS_LEVEL_OFFSET)
  #Check for wrong QoS
  if msg.msgBase.qos > EXACTLY_ONCE
    throw(ErrorException("QOS LEVEL NOT ALLOWED!"))
  end
  #Read DUP flag
  msg.msgBase.dup = (((fixedHeaderFirstByte & DUP_FLAG_MASK) >> DUP_FLAG_OFFSET) == 0x01)
  #Read Retain flag
  msg.msgBase.retain = (((fixedHeaderFirstByte & RETAIN_FLAG_MASK) >> RETAIN_FLAG_OFFSET) == 0x01)

  #Message id is only valid with QoS lvl1&2
  if ((msg.msgBase.qos == AT_LEAST_ONCE) || msg.msgBase.qos == EXACTLY_ONCE)
    msg.msgBase.msgId = (buffer[index] << 8) & 0xFF00
    index += 1
    msg.msgBase.msgId |= buffer[index]
    index += 1
  end

  #Get Payload
  messageSize::Int = remainingLength - index + 1
  remaining::Int = messageSize
  messageOffset = 1
  msg.message = Vector{UInt8}(messageSize)
  #copy first part of payload data received
  copy!(msg.message, messageOffset, buffer, index, ((received - index) + 1))
  remaining -= (received - index)
  messageOffset += (received - index)

  return msg
end
