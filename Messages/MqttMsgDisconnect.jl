include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt Disconnect packages
mutable struct MqttMsgDisconnect <: MqttPacket
    msgBase::MqttMsgBase


  function MqttMsgDisconnect(base::MqttMsgBase = MqttMsgBase(DISCONNECT_TYPE, UInt16(0)))
    return new(base)
  end
end # struct

# Serialize MQTT message disconnect
# returns a byte array
function Serialize(msg::MqttMsgDisconnect)

    buffer = Array{UInt8, 1}(2)
    buffer[1] = msg.msgBase.fixedHeader
    buffer[2] = UInt8(0) #reaminingLength field

    return buffer
end
