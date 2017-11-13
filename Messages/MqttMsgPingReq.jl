
include("Definitions.jl")
include("MqttMsgBase.jl")

mutable struct MqttMsgPingReq <: MqttPacket
    msgBase::MqttMsgBase

    # default constructor
    MqttMsgPingReq() = new(MqttMsgBase(PINGREQ_TYPE))

end # struct

# Serialize MQTT message ping request
# returns a byte array
function Serialize(msgPingReq::MqttMsgPingReq)

    msgPacket = Array{UInt8, 1}(2)
    msgPacket[1] = msgPingReq.msgBase.fixedHeader
    msgPacket[2] = 0 #reaminingLength field

    return msgPacket
end

"""
m = MqttMsgPingReq()
println(m)
b = Serialize(m)
println(b)
"""
