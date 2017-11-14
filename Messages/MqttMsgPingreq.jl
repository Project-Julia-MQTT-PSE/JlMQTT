
include("MqttMsgBase.jl")

mutable struct MqttMsgPingreq <: MqttPacket
    msgBase::MqttMsgBase

    # default constructor
    MqttMsgPingreq() = new(MqttMsgBase(PINGREQ_TYPE))

end # struct

# Serialize MQTT message ping request
# returns a byte array
function Serialize(msgPingreq::MqttMsgPingreq)

    msgPacket = Array{UInt8, 1}(2)
    msgPacket[1] = msgPingreq.msgBase.fixedHeader
    msgPacket[2] = 0 #reaminingLength field

    return msgPacket
end

"""
m = MqttMsgPingreq()
println(m)
b = Serialize(m)
println(b)
"""
