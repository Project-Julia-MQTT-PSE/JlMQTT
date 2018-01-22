include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

#Mqtt unsuback Package
mutable struct MqttMsgUnsuback <: MqttPacket
    msgBase::MqttMsgBase
end

#Unsuback package constructor
function MqttMsgUnsubackConstructor(base::MqttMsgBase = MqttMsgBase(UNSUBACK_TYPE, UInt16(0)))
  return MqttMsgUnsuback(base)
end

# Deserialize MQTT message unsuback
#REturn a MqttMsgUnsuback Package
function MsgUnsubackParse(network::MqttNetworkChannel)
  index::Int = 1
  msg::MqttMsgUnsuback = MqttMsgUnsubackConstructor()

  remainingLength = decodeRemainingLength(network)
  buffer = Vector{UInt8}(remainingLength)

  Read(network, buffer)

  msg.msgBase.msgId = (UInt8(buffer[index]) << 8) & 0x00FF
  index += 1
  msg.msgBase.msgId |= UInt8(buffer[index])

  return msg
end
