include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
JlMQTT.MqttMsgPingresp

Ping rresponse package
"""
#Nqtt Ping response package
mutable struct MqttMsgPingresp <: MqttPacket
    msgBase::MqttMsgBase
end

"""
JlMQTT.MqttMsgPingrespConstructor(msgBase = MqttMsgBase(PINGRESP_TYPE, UInt16(0)))

Ping response constructor

## Parameters:
\nmsgBase - [optional] ['MqttMsgBase'](@ref)

## Returns:
\n[out] - ['MqttMsgPingresp'](@ref)

"""
#Ping response constructor
function MqttMsgPingrespConstructor(msgBase = MqttMsgBase(PINGRESP_TYPE, UInt16(0)))
    return MqttMsgPingresp(msgBase)
end

"""
JlMQTT.MsgPingrespParse(network::MqttNetworkChannel)

Deserializes MQTT ping response message.

## Parameters:
\nnetwork - ['MqttNetworkChannel']('@ref')
## Returns:
\n[out] - ['MqttMsgPingresp'](@ref)

"""
# Deserialize MQTT message ping response
#Return an MqttMsgPingresp package
function MsgPingrespParse(network::MqttNetworkChannel)
    msg::MqttMsgPingresp = MqttMsgPingrespConstructor()
    remainingLength::Int = 0
    remainingLength = decodeRemainingLength(network)
    return msg
end
