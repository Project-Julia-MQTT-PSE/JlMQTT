
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPuback <: MqttPacket
    msgBase::MqttMsgBase

    # constructor
    function MqttMsgPuback(msgBase = MqttMsgBase(PUBACK_TYPE, UInt16(0)))
        return new(msgBase)
    end # function
end # struct

# Deserialize MQTT message publish acknowledge
function MsgPubackParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgPuback = MqttMsgPuback()

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.msgBase.msgId = (buffer[1] << 8) & 0xFF00
    msg.msgBase.msgId |= buffer[2]

        println("MESSAGE ID")
            println(msg.msgBase.msgId)
    return msg
end
