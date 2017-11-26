
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPubrec <: MqttPacket
    msgBase::MqttMsgBase

    # default constructor
    MqttMsgPubrec() = new(MqttMsgBase(PUBREC_TYPE, UInt16(0)))

    # constructor
    function MqttMsgPubrec(messageId::UInt8; msgBase = MqttMsgBase(PUBREC_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

# Deserialize MQTT message publish receive
function MsgPubrecParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgPubrec = MqttMsgPubrec()

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.msgBase.msgId = (buffer[1] << 8) & 0xFF00
    msg.msgBase.msgId |= buffer[2]

    println("MESSAGE ID")
        println(msg.msgBase.msgId)
    return msg
end
