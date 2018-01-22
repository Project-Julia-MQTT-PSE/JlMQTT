include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
JlMQTT.MqttMsgDisconnect

Disconnect package
"""
#Mqtt Disconnect packages
mutable struct MqttMsgDisconnect <: MqttPacket
    msgBase::MqttMsgBase
end

"""
JlMQTT.MqttMsgDisconnectConstructor(base::MqttMsgBase = MqttMsgBase(DISCONNECT_TYPE, UInt16(0)))

Disconnects package constructor

## Parameters:
\nbase - [optional] type ['MqttMsgBase'](@ref)

## Returns:
\n[out] ['MqttMsgDisconnect'](@ref)

"""
#Disconnect package constructor
function MqttMsgDisconnectConstructor(base::MqttMsgBase = MqttMsgBase(DISCONNECT_TYPE, UInt16(0)))
  return MqttMsgDisconnect(base)
end

"""
JlMQTT.Serialize(msg::MqttMsgDisconnect)

## Parameters:
\nmsg - [in] ['MqttMsgDisconnect'](@ref)

## Returns:
\nbuffer - type UInt8 array
"""
# Serialize MQTT message disconnect
# returns a byte array
function Serialize(msg::MqttMsgDisconnect)
    buffer = Array{UInt8, 1}(2)
    buffer[1] = msg.msgBase.fixedHeader
    buffer[2] = UInt8(0)
    return buffer
end
