include("Definitions.jl")
include("MqttMsgBase.jl")

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const QOS_LEVEL_MASK = 0x06

#=Represent a Subscribe Package which can be send to the Broker
fixedHeader = the FixedHeader value
topic = topic to which the message will be published
messageId = OPTIONAL, only required if QoS level is set to level 1 or 2, to identify a specific message
=#

mutable struct MqttMsgSubscribe <: MqttPacket
  msgBase::MqttMsgBase
  topics::Vector{String}
  qosLevels::Vector{UInt8}

  function MqttMsgSubscribe(
  msgBase::MqttMsgBase,
  topics::Vector{String},
  qosLevels::Vector{UInt8})
  return new(msgBase, topics, qosLevels)
  end
end

function Serialize(msgSubscribe::MqttMsgSubscribe)
  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

  #topic list empty
  if size(msgSubscribe.topics) < 1
    throw(ErrorException("Topic list can't be empty"))
  end
  #qos levels list empty
  if size(msgSubscribe.qosLevels) < 1
    throw(ErrorException("Qos List can't be empty"))
  end
  #topic and qos list lenght must match
  if size(msgSubscribe.topics) != size(msgSubscribe.qosLevels)
    throw(ErrorException("Topic & Qos List don't match in size"))
  end

  varHeaderSize += MESSAGE_ID_SIZE

  topicIdx::Int = 1
  topicUtf8 = Array{UInt8}(size(msgSubscribe.topics,))

  while true
    if topicIdx < size(msgSubscribe.topics)
      break
    end
    #Check topic length
    if size(msgSubscribe.topics[topicIdx]) < MIN_TOPIC_LENGTH || size(msgSubscribe.topics[topicIdx]) > MAX_TOPIC_LENGTH
        throw(ErrorException("Topic doesn't match allowed length"))
    end

    topicUtf8[topicIdx] = convert(Array{UInt8}, msgSubscribe.topics[topicIdx])
    payloadSize += 2 #topic size (MSB, LSB)
    payloadSize += size(topicsUtf8[topicIdx])
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
  buffer[index] = (SUBSCRIBE_TYPE << MSG_TYPE_OFFSET) | SUBSCRIBE_FLAG_BITS
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

  topicIdx = 0

  while true
    if topicIdx < msgSubscribe.topics
      break
    end
      #topic name
      buffer[index] = (size(topicUtf8[index]) >> 8) & 0x00FF #MSB
      index += 1
      buffer[index] = size(topicUtf8[index]) & 0x00FF #LSB
      index += 1
      copy!(buffer, index, topicsUtf8[topicIdx], 0, size(topicsUtf8[topicIdx]))
      index += size(topicsUtf8[topicIdx])
      #qos
      buffer[index] = msgSubscribe.qosLevels[topicIdx]
      index += 1
      topicIdx += 1
  end
  return buffer
end
