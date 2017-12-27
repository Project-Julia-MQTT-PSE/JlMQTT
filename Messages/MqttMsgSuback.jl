include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

# Suback Package
mutable struct MqttMsgSuback <: MqttPacket
  msgBase::MqttMsgBase
  grantedQosLevels::Vector{UInt8}
end

#Suback package constructor
function MqttMsgSubackConstructor(base = MqttMsgBase(SUBACK_TYPE, UInt16(0)), grQosLevels::Vector{UInt8} = Array{UInt8}(5))
  return MqttMsgSuback(base, grQosLevels)
end

#Parse a SUBACK Message
#Return a MqttMsgSuback Package
function MsgSubackParse(network::MqttNetworkChannel)
  index::Int = 1
  msg::MqttMsgSuback = MqttMsgSubackConstructor()

  remainingLength = decodeRemainingLength(network)
  buffer = Vector{UInt8}(remainingLength)
  Read(network, buffer)
  msg.msgBase.msgId = UInt8((buffer[index] << 8) & 0xFF00)
  index += 1
  msg.msgBase.msgId |= buffer[index]
  index += 1
  msg.grantedQosLevels = Array{UInt8}(remainingLength - MESSAGE_ID_SIZE)
  qosIdx = 1
  while true
    msg.grantedQosLevels[qosIdx] = buffer[index]
    qosIdx += 1
    index += 1
    if index > remainingLength
      break
    end
  end
  return msg
end
