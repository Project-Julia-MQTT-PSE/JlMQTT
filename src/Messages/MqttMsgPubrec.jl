include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")


"""
JlMQTT.MqttMsgPubrec

Mqtt Pubrec Package

"""
#Mqtt Pubrec Package
mutable struct MqttMsgPubrec <: MqttPacket
    msgBase::MqttMsgBase
end

"""
JlMQTT.MqttMsgPubrecConstructor(msgBase = MqttMsgBase(PUBREC_TYPE, UInt16(0)))

Pubrec package constructor

## Parameters:
\n[optional][`JlMQTT.MqttMsgBase`](@ref)
## Returns:
\n[out] Pubrec package
"""

#Pubrec package constructor
function MqttMsgPubrecConstructor(msgBase = MqttMsgBase(PUBREC_TYPE, UInt16(0)))
    return MqttMsgPubrec(msgBase)
end

"""
JlMQTT.Serialize(msg::MqttMsgPubrec)

Serialize MQTT message publish received.

## Parameters:
\n[in][`JlMQTT.MqttMsgPubrec`](@ref)
## Returns:
\n[out] Byte Array
"""

# Serialize MQTT message publish receeived
#REturn Byte Array
function Serialize(msg::MqttMsgPubrec)
  fixedHeaderSize::Int = 1
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength = 0
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
"""
JlMQTT.MsgPubrecParse(network::MqttNetworkChannel)

Deserialize MQTT message publish receive

## Parameters:
\n[in][`JlMQTT.MqttNetworkChannel`](@ref)
## Returns:
\n[out] MqttMsgPubrec Package
"""

# Deserialize MQTT message publish receive
#return MqttMsgPubrec Package
function MsgPubrecParse(network::MqttNetworkChannel)
    remainingLength::Int = 0
    msg::MqttMsgPubrec = MqttMsgPubrecConstructor()
    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.msgBase.msgId = (buffer[1] << 8) & 0xFF00
    msg.msgBase.msgId |= buffer[2]
    return msg
end
