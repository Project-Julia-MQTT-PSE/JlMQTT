include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPingresp <: MqttPacket
    msgBase::MqttMsgBase

    # constructor
    function MqttMsgPingresp(msgBase = MqttMsgBase(PINGRESP_TYPE, UInt16(0)))
        return new(msgBase)
    end # function
end # struct

# Deserialize MQTT message ping response
function MsgPingrespParse(network::MqttNetworkChannel)

    msg::MqttMsgPingresp = MqttMsgPingresp()
    remainingLength::Int = 0

    remainingLength = decodeRemainingLength(network)

    return msg
end
