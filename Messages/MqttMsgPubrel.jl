
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

mutable struct MqttMsgPubrel <: MqttPacket
    msgBase::MqttMsgBase
    messageId::UInt8

    # default constructor
    MqttMsgPubrel() = new(MqttMsgBase(PUBREL_TYPE), 0)

    # constructor
    function MqttMsgPubrel(messageId::UInt8; msgBase = MqttMsgBase(PUBREL_TYPE))
        return new(msgBase, messageId)
    end # function
end # struct

# Deserialize MQTT message publish release
# returns a byte array
function Serialize(msg::MqttMsgPubrel)

    msgPacket = Array{UInt8, 1}(2)
    msgPacket[1] = msg.msgBase.fixedHeader
    msgPacket[2] = 2 #reaminingLength field

    # MSB
    msgPacket[1] = (msg.messageId >> 8) & 0x00FF
    # LSB
    msgPacket[2] = msg.messageId & 0x00FF

    return msgPacket
end
