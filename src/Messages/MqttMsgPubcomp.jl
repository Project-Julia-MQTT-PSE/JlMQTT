include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
JlMQTT.MqttMsgPubcomp

Mqtt Pubcomp Package

"""
#Mqtt Pubcomp Package
mutable struct MqttMsgPubcomp <: MqttPacket
    msgBase::MqttMsgBase
end

"""
JlMQTT.MqttMsgPubcompConstructor(msgBase = MqttMsgBase(PUBCOMP_TYPE, UInt16(0)))

Pubcomp package constructor

## Parameters:
\n[optional][`JlMQTT.MqttMsgBase`](@ref)
## Returns:
\n[out] MqttMsgPubcomp package.
"""

#Pubcomp package constructor
function MqttMsgPubcompConstructor(msgBase = MqttMsgBase(PUBCOMP_TYPE, UInt16(0)))
    return MqttMsgPubcomp(msgBase)
end

"""
JlMQTT.Serialize(message::MqttMsgPubcomp)

Serialize a MqttMsgPubcomp package.

## Parameters:
\n[in][`JlMQTT.MqttMsgPubcomp`](@ref)
## Returns:
\n[out] Byte array.
"""
#Serialize a MqttMsgPubcomp package
#Return a Byte Array
function Serialize(message::MqttMsgPubcomp)

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
  buffer[index] = message.msgBase.fixedHeader
  index += 1

  index = encodeRemainingLength(remainingLength, buffer, index)

  buffer[index] = (message.msgBase.msgId >> 8) & 0x00FF #MSB
  index += 1
  buffer[index] = message.msgBase.msgId & 0x00FF #LSB

  return buffer
end

"""
JlMQTT.MqttMsgPubcompParse(network::MqttNetworkChannel)

Deserialize MQTT message publish complete

## Parameters:
\n[in][`JlMQTT.MqttNetworkChannel`](@ref)
## Returns:
\n[out] MqttMsgPubcomp Package
"""
# Deserialize MQTT message publish complete
#Return a MqttMsgPubcomp Package
function MqttMsgPubcompParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgPubcomp = MqttMsgPubcompConstructor()

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.msgBase.msgId = (buffer.at(1) << 8) & 0xFF00
    msg.msgBase.msgId |= buffer.at(2)

    return msg
end
