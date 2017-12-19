include("Definitions.jl")
include("MqttMsgBase.jl")

#A Context Package which describes the status of an Message Package
mutable struct MqttMsgContext
  message
  state::MqttMsgState
  flow::MqttMsgFlow
  timestamp::Int
  attempt::Int

  function MqttMsgContext(message, state::MqttMsgState, flow::MqttMsgFlow; timestamp::Int = 1, attempt::Int = 1)
    return new(message, state, flow, timestamp, attempt)
  end
end

