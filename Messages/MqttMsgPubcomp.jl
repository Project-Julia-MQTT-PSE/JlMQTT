
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPubcomp <: MqttPacket
    msgBase::MqttMsgBase
    messageId::UInt8

    # default constructor
    MqttMsgPubcomp() = new(MqttMsgBase(PUBCOMP_TYPE), 0)

    # constructor
    function MqttMsgPubcomp(messageId::UInt8; msgBase = MqttMsgBase(PUBCOMP_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

#Serialize a MqttMsgPubcomp package to send it
function Serialize(msgConnect::MqttMsgPubcomp)

  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

  varHeaderSize += MESSAGE_ID_SIZE
  remainingLength += (varHeaderSize + payloadSize)

  tmp::Int = remainingLength

  while true
    fixedHeaderSize += 1
    tmp = round(tmp / 128)
    if !(tmp > 0)
      break
    end
  end

  buffer = Array{UInt8}(fixedHeaderSize + varHeaderSize + payloadSize)
  buffer[index] = (PUBCOMP_TYPE << MSG_TYPE_OFFSET) | PUBCOMP_FLAG_BITS
  index += 1

  index = encodeRemainingLength(remainingLength, buffer, index)

  buffer[index] = (messageId >> 8) & 0x00FF #MSB
  index += 1
  buffer[index] = messageId & 0x00FF #LSB

  return buffer
end

# Deserialize MQTT message publish complete
function Deserialize(msg::MqttMsgPubcomp, network::MqttNetworkChannel)

    remainingLength::Int = 0
    buffer::Vector{UInt8}

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    numberOfBytes = Receive(network, buffer)
    msg.messageId = (buffer.at(1) << 8) & 0xFF00
    msg.messageId |= buffer.at(2)

    return msg
end
