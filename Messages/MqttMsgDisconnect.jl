include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt Ping request package
mutable struct MqttMsgPingreq <: MqttPacket
    msgBase::MqttMsgBase
    # default constructor
  function MqttMsgPingreq(base::MqttMsgBase = MqttMsgBase(PINGREQ_TYPE, UInt16(0)))
    return new(base)
  end
end # struct

# Serialize MQTT message ping request
# returns a byte array
function Serialize(msg::MqttMsgPingreq)

    buffer = Array{UInt8, 1}(2)
    buffer[1] = msg.msgBase.fixedHeader
    buffer[2] = UInt8(0) #reaminingLength field

    return buffer
end
