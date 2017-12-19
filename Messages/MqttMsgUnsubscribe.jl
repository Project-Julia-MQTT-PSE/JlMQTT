include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt Unsubscibe Package
mutable struct MqttMsgUnsubscribe <: MqttPacket
    msgBase::MqttMsgBase
    topics::Vector{String}
    function MqttMsgUnsubscribe(base::MqttMsgBase = MqttMsgBase(UNSUBACK_TYPE, UInt16(0)), topics::Vector{String} = Vector{String})
      return new(base, topics)
    end
end

# Serialize MQTT message Unsubscibe
#REturn Byte Array
function Serialize(msgUnsubscribe::MqttMsgUnsubscribe)
  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

    #topic list empty
    if length(msgUnsubscribe.topics) < 1
      throw(ErrorException("Topic list can't be empty"))
    end

    varHeaderSize += MESSAGE_ID_SIZE

    topicIdx::Int = 1
    topicsUtf8 = Vector{Vector{UInt8}}(length(msgUnsubscribe.topics))

    while topicIdx <= length(msgUnsubscribe.topics)
      if length(msgUnsubscribe.topics[topicIdx]) < MIN_TOPIC_LENGTH || length(msgUnsubscribe.topics[topicIdx]) > MAX_TOPIC_LENGTH
        throw(ErrorException("Wrong Topic length!"))
      end

      topicsUtf8[topicIdx] = convert(Array{UInt8}, msgUnsubscribe.topics[topicIdx])
      payloadSize += 2
      payloadSize += length(msgUnsubscribe.topics[topicIdx])
      topicIdx += 1
    end
    remainingLength += (varHeaderSize + payloadSize)

    tmp::Int = remainingLength

    while true
      fixedHeaderSize += 1
      tmp = round(tmp / 128)
      if !(tmp > 0)
        break
      end
    end

    #allocate buffer
    buffer = Array{UInt8}(fixedHeaderSize + varHeaderSize + payloadSize)
    buffer[index] = (UInt8(UNSUBSCRIBE_TYPE) << MSG_TYPE_OFFSET) | UNSUBSCRIBE_FLAG_BITS
    index += 1
    index = encodeRemainingLength(remainingLength, buffer, index)

    if msgUnsubscribe.msgBase.msgId == 0
      throw(ErrorException("Wrong message ID"))
    end

    buffer[index] = (msgUnsubscribe.msgBase.msgId >> 8) & 0x00FF #MsB
    index += 1
    buffer[index] = msgUnsubscribe.msgBase.msgId & 0x00FF #LSB
    index += 1
    topicIdx = 1
    while topicIdx <= length(msgUnsubscribe.topics)
        #topic name
        buffer[index] = (length(topicsUtf8[topicIdx]) >> 8) & 0x00FF #MSB
        index += 1
        buffer[index] = length(topicsUtf8[topicIdx]) & 0x00FF #LSB
        index += 1
        copy!(buffer, index, topicsUtf8[topicIdx], 1, length(topicsUtf8[topicIdx]))
        index += length(topicsUtf8[topicIdx])
        topicIdx += 1
    end
    return buffer
end
