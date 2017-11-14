
include("MqttMsgBase.jl")

mutable struct MqttMsgDisconnect <: MqttPacket
    msgBase::MqttMsgBase

    # default constructor
    MqttMsgDisconnect() = new(MqttMsgBase(DISCONNECT_TYPE))

end # struct

# Serialize MQTT message disconnect
# returns a byte array
function Serialize(msg::MqttMsgDisconnect)

    msgPacket = Array{UInt8, 1}(2)
    msgPacket[1] = msg.msgBase.fixedHeader
    msgPacket[2] = 0 #reaminingLength field

    return msgPacket
end

"""
m = MqttMsgDisconnect()
println(m)
b = Serialize(m)
println(b)
"""
