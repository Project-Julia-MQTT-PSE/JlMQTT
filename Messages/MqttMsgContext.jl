include("Definitions.jl")
include("MqttMsgBase.jl")
mutable struct MqttMsgContext
  message
  state::MqttMsgState
  flow::MqttMsgFlow
  timestamp::Int
  attempt::Int
end
#=
function MqttMsgContext(message::MqttMsgBase, state::MqttMsgState, flow::MqttMsgFlow, timestamp::Int, attempt::Int)
  return MqttMsgContext(message, state, flow, timestamp, attempt)
end
=#
