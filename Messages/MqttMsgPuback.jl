
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPuback <: MqttPacket
    msgBase::MqttMsgBase
    messageId::UInt8

    # default constructor
    MqttMsgPuback() = new(MqttMsgBase(PUBACK_TYPE), 0)

    # constructor
    function MqttMsgPuback(messageId::UInt8; msgBase = MqttMsgBase(PUBACK_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

# Deserialize MQTT message publish acknowledge
function Deserialize(msg::MqttMsgPuback, network::MqttNetworkChannel)

    remainingLength::Int = 0
    buffer::Vector{UInt8}

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    numberOfBytes = Receive(network, buffer)
    msg.messageId = (buffer.at(1) << 8) & 0xFF00
    msg.messageId |= buffer.at(2)

    return msg
end
