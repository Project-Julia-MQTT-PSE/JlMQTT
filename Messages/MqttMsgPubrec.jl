
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPubrec <: MqttPacket
    msgBase::MqttMsgBase
    messageId::UInt8

    # default constructor
    MqttMsgPubrec() = new(MqttMsgBase(PUBREC_TYPE), 0)

    # constructor
    function MqttMsgPubrec(messageId::UInt8; msgBase = MqttMsgBase(PUBREC_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

# Deserialize MQTT message publish receive
function Deserialize(msg::MqttMsgPubrec, network::MqttNetworkChannel)

    remainingLength::Int = 0
    buffer::Vector{UInt8}

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    numberOfBytes = Receive(network, buffer)
    msg.messageId = (buffer.at(1) << 8) & 0xFF00
    msg.messageId |= buffer.at(2)

    return msg
end
