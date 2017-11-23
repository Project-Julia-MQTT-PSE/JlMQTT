include("Definitions.jl")
include("MqttMsgBase.jl")
mutable struct MqttMsgContext
  message::MqttMsgBase
  state::MqttMsgState
  flow::MqttMsgFlow
  timestamp::Int
  attempt::Int
  function MqttMsgContext(message::MqttMsgBase, state::MqttMsgState, flow::MqttMsgFlow, timestamp::Int, attempt::Int)
    return new(message, state, flow, timestamp, attempt)
  end
end
