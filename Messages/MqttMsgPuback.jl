include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt Puback Package
mutable struct MqttMsgPuback <: MqttPacket
    msgBase::MqttMsgBase
    # constructor
    function MqttMsgPuback(msgBase = MqttMsgBase(PUBACK_TYPE, UInt16(0)))
        return new(msgBase)
    end # function
end # struct

# Deserialize MQTT message publish acknowledge
#Return a MqttMsgPuback Package
function MsgPubackParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgPuback = MqttMsgPuback()

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.msgBase.msgId = (buffer[1] << 8) & 0xFF00
    msg.msgBase.msgId |= buffer[2]

    return msg
end

#Serialize a given MqttMsgPuback
#Return a byte Array
function Serialize(message::MqttMsgPuback)

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
