include("Definitions.jl")
include("MqttMsgBase.jl")
include("../MqttNetworkChannel.jl")

"""
JlMQTT.MqttMsgUnsuback

This is the Unsubscribe Acknowledgement Package 

"""
#Mqtt unsuback Package
mutable struct MqttMsgUnsuback <: MqttPacket
    msgBase::MqttMsgBase
end

"""
 JlMQTT.MqttMsgUnsubackConstructor(base::MqttMsgBase = MqttMsgBase(UNSUBACK_TYPE, UInt16(0)))

 ## Parameters:
 \nbase - [in] type ['MqttMsgBase'](@ref)
 
 ## Returns:
 \n[out]  ['MqttMsgUnsuback'](@ref)
 
 """

#Unsuback package constructor
function MqttMsgUnsubackConstructor(base::MqttMsgBase = MqttMsgBase(UNSUBACK_TYPE, UInt16(0)))
  return MqttMsgUnsuback(base)
end

"""
 JlMQTT.MsgUnsubackParse(network::MqttNetworkChannel)
  index::Int = 1
  msg::MqttMsgUnsuback = MqttMsgUnsubackConstructor()

  remainingLength = decodeRemainingLength(network)
  buffer = Vector{UInt8}(remainingLength)

 ## Parameters:
 \nnetwork - [in] type ['MqttNetworkChannel'](@ref)
 \nindex - [optional] type Int
 \nmsg - [optional] type ['MqttMsgUnsuback'](@ref)
 \nremainingLength - [optional] type ['decodeRemainingLength'](@ref)
 \nbuffer - [optional] type Vector{UInt8}
 
 ## Returns:
 \n[out]  msg['MqttMsgUnsuback'](@ref)
 
 """
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
