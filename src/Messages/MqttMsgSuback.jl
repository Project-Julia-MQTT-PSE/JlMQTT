include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

 +"""
 +JlMQTT.MqttMsgSuback
 +
 +Subscribe Acknowledgement Package
 +
 +"""

mutable struct MqttMsgSuback <: MqttPacket
  msgBase::MqttMsgBase
  grantedQosLevels::Vector{UInt8}

  #MqttMsgSuback() = new(MqttMsgBase(SUBACK_TYPE, UInt16(0)), 0, Array{UInt8}(1))
  
 """
 +JlMQTT.MqttMsgSuback(base = MqttMsgBase(SUBACK_TYPE, UInt16(0)), grQosLevels::Vector{UInt8} = Array{UInt8}(5))
    return new(base, grQosLevels)
 +
 +## Parameters:
 +\nbase - [in] type ['MqttMsgBase'](@ref)
 +\ngrQoSLevels - [in] type Vector{UInt8} = Array{UInt8}(5)
 +
 +## Returns:
 +\n[out]  new(base, grQosLevels)(@ref)
 +
 +"""

  function MqttMsgSuback(base = MqttMsgBase(SUBACK_TYPE, UInt16(0)), grQosLevels::Vector{UInt8} = Array{UInt8}(5))
    return new(base, grQosLevels)
  end
end

 +"""
 +JlMQTT.MsgSubackParse(network::MqttNetworkChannel)
 +
 +## Parameters:
 +\nnetwork - [in] type ['MqttNetworkChannel'](@ref)
 +
 +## Returns:
 +\n[out]  msg(@ref)
 +
 +"""

#Parse a SUBACK Message from the inbound stream
function MsgSubackParse(network::MqttNetworkChannel)
  index::Int = 1
  msg::MqttMsgSuback = MqttMsgSuback()

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
    #POTENTIAL FUTURE ERROR IN THE IF CONDITION
    if index > remainingLength
      break
    end
  end
  return msg
end
