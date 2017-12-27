include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Represent the Connack package
mutable struct MqttMsgConnack <: MqttPacket
    msgBase::MqttMsgBase
    returnCode::ConnackCode
    sessionPresent::Bool
end

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
