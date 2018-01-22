include("Definitions.jl")
include("MqttMsgBase.jl")

"""
JlMQTT.MqttMsgContext

A context package which describes the status of a message package.

"""
#A Context Package which describes the status of an Message Package
mutable struct MqttMsgContext
  message
  state::MqttMsgState
  flow::MqttMsgFlow
  timestamp::Int
  attempt::Int
end

"""
JlMQTT.MqttMsgContextConstructor(message, state::MqttMsgState, flow::MqttMsgFlow; timestamp::Int = 1, attempt::Int = 1)

## Parameters:
\nmessage - [in] type String
\nstate - [in] type ['MqttMsgState'](@ref)
\nflow - [in] type ['MqttMsgFlow'](@ref)
\ntimestamp - [optional] type int
\nattempt - [optional] type int

## Returns:
\n[out]  ['MqttMsgContext'](@ref)

"""
#Message Context Constructor
function MqttMsgContextConstructor(message, state::MqttMsgState, flow::MqttMsgFlow; timestamp::Int = 1, attempt::Int = 1)
  return MqttMsgContext(message, state, flow, timestamp, attempt)
end
