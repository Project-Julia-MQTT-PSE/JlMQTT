# MQTT Client
include("Messages/Definitions.jl")
include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("ReceivedMessage.jl")

#Session struct
#UNUSED
mutable struct MqttSession
    clientId::String
    inFlightMessages::Dict
end

#Client, stores all relevant variable to run the interface
mutable struct MqttClient
  channel::MqttNetworkChannel
  lastCommTime::Int
  isRunning::Bool
  session::MqttSession
  clientId::String
  keepAlivePeriod::UInt16
  staticMsgId::UInt16
  sendReceiveChannel
  subscribedTopicMsgChannel
  contextMsgChannel
  contextQueueLock
end

#Client constructor
function MqttClientConstructor(
  channel::MqttNetworkChannel = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883),
  lastCommTime::Int = 0,
  isRunning::Bool = true,
  session::MqttSession = MqttSession(String(""), Dict()),
  clientId::String = String(""),
  keepAlivePeriod::UInt16 = UInt16(KEEP_ALIVE_PERIOD_DEFAULT),
  staticMsgId::UInt16 = UInt16(1),
  sendReceiveChannel::Channel{Any} = Channel{Any}(1),
  subscribedTopicMsgChannel::Channel{ReceivedMessage} = Channel{ReceivedMessage}(10),
  contextMsgChannel::Channel{Any} = Channel{Any}(30),
  contextQueueLock = Threads.Mutex())

  return MqttClient(channel, lastCommTime, isRunning, session, clientId, keepAlivePeriod, staticMsgId,
  sendReceiveChannel, subscribedTopicMsgChannel, contextMsgChannel, contextQueueLock)
  return a
end
