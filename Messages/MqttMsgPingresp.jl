
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPingresp <: MqttPacket
    msgBase::MqttMsgBase
    messageId::UInt8

    # default constructor
    MqttMsgPingresp() = new(MqttMsgBase(PINGRESP_TYPE), 0)

    # constructor
    function MqttMsgPingresp(messageId::UInt8; msgBase = MqttMsgBase(PINGRESP_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

# Deserialize MQTT message ping response
function Deserialize(msg::MqttMsgPingresp, network::MqttNetworkChannel)

    remainingLength::Int = 0
    buffer::Vector{UInt8}

    remainingLength = decodeRemainingLength(network)
    if remainingLength > 0
        buffer = Vector{UInt8}(remainingLength)
        numberOfBytes = Receive(network, buffer)
    end

    return msg
end
