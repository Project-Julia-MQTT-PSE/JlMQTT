include("Definitions.jl")
include("MqttMsgBase.jl")

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const QOS_LEVEL_MASK = 0x06

"""
JlMQTT.MqttMsgSubscribe

Subscribe Package 

"""
# Subscribe Package
mutable struct MqttMsgSubscribe <: MqttPacket
  msgBase::MqttMsgBase
  topics::Vector{String}
  qosLevels::Vector{UInt8}
end

"""
 JlMQTT.MqttMsgSubscribeConstructor(msgBase::MqttMsgBase, topics::Vector{String}, qosLevels::Vector{UInt8})

 ## Parameters:
 \nmsgBase - [in] type ['MqttMsgBase'](@ref)
 \ntopics - [in] type Vector{String}
 \nqosLevels - [in] type Vector{String}
 
 ## Returns:
 \n[out]  ['MqttMsgSubscribe'](@ref)
 
 """
#Subscribe package constructor
function MqttMsgSubscribeConstructor(
msgBase::MqttMsgBase,
topics::Vector{String},
qosLevels::Vector{UInt8})
return MqttMsgSubscribe(msgBase, topics, qosLevels)
end

"""
 JlMQTT.Serialize(msgSubscribe::MqttMsgSubscribe)
  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

 ## Parameters:
 \nmsgSubscribe - [in] type ['MqttMsgSubscribe'](@ref)
 \nfixedHeaderSize - [optional] type Int
 \nvarHeaderSize - [optional] type Int
 \npayloadSize - [optional] type Int
 \nremainingLength - [optional] type Int
 \nindex - [optional] type Int


 
 ## Returns:
 \n[out]  buffer 
  buffer = Array{UInt8}(fixedHeaderSize + varHeaderSize + payloadSize)
 
 """

# Serialize MQTT message Subscribe
#REturn byte Array
function Serialize(msgSubscribe::MqttMsgSubscribe)
  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

  #topic list empty
  if length(msgSubscribe.topics) < 1
    throw(ErrorException("Topic list can't be empty"))
  end
  #qos levels list empty
  if length(msgSubscribe.qosLevels) < 1
    throw(ErrorException("Qos List can't be empty"))
  end
  #topic and qos list lenght must match
  if length(msgSubscribe.topics) != length(msgSubscribe.qosLevels)
    throw(ErrorException("Topic & Qos List don't match in size"))
  end

  varHeaderSize += MESSAGE_ID_SIZE

  topicIdx::Int = 1
  topicUtf8 = Vector{Vector{UInt8}}(length(msgSubscribe.topics))

  while true
    if topicIdx > length(msgSubscribe.topics)
      break
    end
    #Check topic length
    if length(msgSubscribe.topics[topicIdx]) < MIN_TOPIC_LENGTH || length(msgSubscribe.topics[topicIdx]) > MAX_TOPIC_LENGTH
        throw(ErrorException("Topic doesn't match allowed length"))
    end

    topicUtf8[topicIdx] = convert(Array{UInt8}, msgSubscribe.topics[topicIdx])
    payloadSize += 2 #topic size (MSB, LSB)
    payloadSize += length(topicUtf8[topicIdx])
    payloadSize += 1 #Qos Byte
    topicIdx += 1
  end

  remainingLength += (varHeaderSize + payloadSize)

  tmp::Int = remainingLength
  #Add Length to Fixed header depending on the remainging length
  while true
    fixedHeaderSize += 1
    tmp = round(tmp / 128)
    if !(tmp > 0)
      break
    end
  end
  #allocate buffer
  buffer = Array{UInt8}(fixedHeaderSize + varHeaderSize + payloadSize)
  #fixed header first
  buffer[index] = (UInt8(SUBSCRIBE_TYPE) << MSG_TYPE_OFFSET) | SUBSCRIBE_FLAG_BITS
  index += 1
  #encode remainingLength
  index = encodeRemainingLength(remainingLength, buffer, index)
  #Subscribe use QOS = ! Message ID required
  if msgSubscribe.msgBase.msgId == 0
    throw(ErrorException("Wrong message ID"))
  end
  buffer[index] = (msgSubscribe.msgBase.msgId >> 8) & 0x00FF #MsB
  index += 1
  buffer[index] = msgSubscribe.msgBase.msgId & 0x00FF #LSB
  index += 1

  topicIdx = 1

  while true
    if topicIdx > length(msgSubscribe.topics)
      break
    end
      #topic name
      buffer[index] = (length(topicUtf8[topicIdx]) >> 8) & 0x00FF #MSB
      index += 1
      buffer[index] = length(topicUtf8[topicIdx]) & 0x00FF #LSB
      index += 1
      copy!(buffer, index, topicUtf8[topicIdx], 1, length(topicUtf8[topicIdx]))
      index += length(topicUtf8[topicIdx])
      #qos
      buffer[index] = msgSubscribe.qosLevels[topicIdx]
      index += 1
      topicIdx += 1
  end
  return buffer
end
