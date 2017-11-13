
include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

# CONSTANTS


mutable struct MqttMsgConnack <: MqttPacket
    msgBase::MqttMsgBase
    returnCode::ConnackCode
    sessionPresent::Bool

    # default constructor
    MqttMsgConnack() = new(MqttMsgBase(CONNACK_TYPE), CONN_ACCEPTED, 0)

    # constructor
    function MqttMsgConnack(returnCode::ConnackCode, sessionPresent::Bool; msgBase = MqttMsgBase(CONNACK_TYPE))

        this = new()
        this.msgBase = MqttMsgBase(CONNACK_TYPE)
        this.returnCode = returnCode
        this.sessionPresent = sessionPresent

        return this
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
# returns a byte array
function Deserialize(msgConnack::MqttMsgConnack, network::MqttNetworkChannel)

    remainingLength::Int = 0
    buffer::Vector{UInt8}

    remainingLength = decodeRemainingLength(network)
    buffer = Vector{UInt8}(remainingLength)
    numberOfBytes = Receive(network, buffer)
    msgConnack.sessionPresent = (buffer[1] & 0x00) != 0x00
    msgConnack.returnCode = buffer[2]

    return msgConnack
end
