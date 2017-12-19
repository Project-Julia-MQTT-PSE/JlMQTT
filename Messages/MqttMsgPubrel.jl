include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt Pubrel Package
mutable struct MqttMsgPubrel <: MqttPacket
    msgBase::MqttMsgBase

    # default constructor
    MqttMsgPubrel() = new(MqttMsgBase(PUBREL_TYPE), 0)

    # constructor
    function MqttMsgPubrel(msgBase = MqttMsgBase(PUBREL_TYPE, UInt16(0)))
        return new(msgBase)
    end # function
end # struct

# Deserialize MQTT message publish release
# returns a byte array
function Serialize(msg::MqttMsgPubrel)
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
  buffer[index] = msg.msgBase.fixedHeader
  index += 1

  index = encodeRemainingLength(remainingLength, buffer, index)

  buffer[index] = (msg.msgBase.msgId >> 8) & 0x00FF #MSB
  index += 1
  buffer[index] = msg.msgBase.msgId & 0x00FF #LSB

  return buffer
end

# Deserialize MQTT message publish release
#REturn Byte Array
function MsgPubrelParse(network::MqttNetworkChannel)
      remainingLength::Int = 0
      msg::MqttMsgPubrel = MqttMsgPubrel()
      remainingLength = decodeRemainingLength(network)
      buffer = Vector{UInt8}(remainingLength)
      Read(network, buffer)
      msg.msgBase.msgId = (buffer[1] << 8) & 0xFF00
      msg.msgBase.msgId |= buffer[2]
      return msg
end
