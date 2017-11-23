
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgConnack <: MqttPacket
    msgBase::MqttMsgBase
    returnCode::ConnackCode
    sessionPresent::Bool

    # default constructor
    #MqttMsgConnack() = new(MqttMsgBase(CONNACK_TYPE, UInt16(0)), CONN_ACCEPTED, false)

    # constructor
    function MqttMsgConnack(returnCode::ConnackCode, sessionPresent::Bool; msgBase::MqttMsgBase = MqttMsgBase(CONNACK_TYPE, UInt16(0)))
        return new(msgBase, returnCode, sessionPresent)
    end # function
end # struct

#=
# Deserialize MQTT message connack
# returns a byte array
function Deserialize(buffer::Array{UInt8, 1})

    if !(length(buffer) > 0) throw(ErrorException("Deserialization error: no data")) end

    msgConnack::MqttMsgConnack = MqttMsgConnack()
    # check fixed header and remaining length field
    if (buffer[1] == 0x20) && (buffer[2] == 0x02)
        msgConnack.sessionPresent = (buffer[3] & 0x01) == 0x01 ? true : false
        msgConnack.returnCode = buffer[4]
    end

    return msgConnack
end
=#

# Deserialize MQTT message connack
function MsgConnackParse(network::MqttNetworkChannel)

    remainingLength::Int = 0
    msg::MqttMsgConnack = MqttMsgConnack(CONN_ACCEPTED, false)

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    Read(network, buffer)
    msg.sessionPresent = (buffer[1] & 0x00) != 0x00
    msg.returnCode = buffer[2]
    return msg
end
