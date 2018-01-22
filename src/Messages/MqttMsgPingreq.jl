include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
JlMQTT.MqttMsgPingreq

Ping request package
"""
#Mqtt Ping request package
mutable struct MqttMsgPingreq <: MqttPacket
    msgBase::MqttMsgBase
end

"""
JlMQTT.MqttMsgPingreqConstructor(base::MqttMsgBase = MqttMsgBase(PINGREQ_TYPE, UInt16(0)))

Ping request constructor

## Parameters:
\nbase - [optional] ['MqttMsgBase'](@ref)

## Returns:
\n[out] - ['MqttMsgPingreq'](@ref)

"""
# Ping request constructor
function MqttMsgPingreqConstructor(base::MqttMsgBase = MqttMsgBase(PINGREQ_TYPE, UInt16(0)))
return MqttMsgPingreq(base)
end

"""
JlMQTT.Serialize(msg::MqttMsgPingreq)

Serializes MQTT message ping request.

## Parameters:
\nmsg - ['MqttMsgPingreq'](@ref)

## Returns:
\nbuffer - type UInt8 array
"""

# Serialize MQTT message ping request
# returns a byte array
function Serialize(msg::MqttMsgPingreq)
    buffer = Array{UInt8, 1}(2)
    buffer[1] = msg.msgBase.fixedHeader
    buffer[2] = UInt8(0)
    return buffer
end
