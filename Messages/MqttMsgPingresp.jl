include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Nqtt Ping response package
mutable struct MqttMsgPingresp <: MqttPacket
    msgBase::MqttMsgBase
end

#Ping response constructor
function MqttMsgPingrespConstructor(msgBase = MqttMsgBase(PINGRESP_TYPE, UInt16(0)))
    return MqttMsgPingresp(msgBase)
end

# Deserialize MQTT message ping response
#Return an MqttMsgPingresp package
function MsgPingrespParse(network::MqttNetworkChannel)
    msg::MqttMsgPingresp = MqttMsgPingrespConstructor()
    remainingLength::Int = 0
    remainingLength = decodeRemainingLength(network)
    return msg
end
