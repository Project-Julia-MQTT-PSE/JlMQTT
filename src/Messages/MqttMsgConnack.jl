include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
  JlMQTT.MqttMsgConnack

Represents the CONNACK message. Constructor: [`JlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)`](@ref)
"""
#Represent the Connack package
mutable struct MqttMsgConnack <: MqttPacket
    msgBase::MqttMsgBase
    returnCode::ConnackCode
    sessionPresent::Bool
end

"""
  JlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)

Constructs a [`JlMQTT.MqttMsgConnack`](@ref).

## Parameters:
\nreturnCode - [`JlMQTT.ConnackCode`](@ref)
\nsessionPresent - session present flag of type Boolean

## Returns:
\n[out] [`JlMQTT.MqttMsgConnack`](@ref)
"""
#Connack constructor
function MqttMsgConnackConstructor(returnCode::ConnackCode, sessionPresent::Bool; msgBase::MqttMsgBase = MqttMsgBase(CONNACK_TYPE, UInt16(0)))
    return MqttMsgConnack(msgBase, returnCode, sessionPresent)
end

# Deserialize MQTT message connack
#Returns a MqttMsgConnack Package
function MsgConnackParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgConnack = MqttMsgConnackConstructor(CONN_ACCEPTED, false)

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.sessionPresent = (buffer[1] & 0x00) != 0x00
    msg.returnCode = buffer[2]
    return msg
end
