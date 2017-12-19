# MQTT Client
include("Messages/Definitions.jl")
include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("ReceivedMessage.jl")

mutable struct MqttSession
    clientId::String
    inFlightMessages::Dict
end

#Mqtt Client Package, stores all relevant variable to run the interface
mutable struct MqttClient
    channel::MqttNetworkChannel
    lastCommTime::Int
    isRunning::Bool
    session::MqttSession
    clientId::String
    cleanSession::Bool
    will::WillOptions
    willFlag::Bool
    keepAlivePeriod::Int
    staticMsgId::UInt16
    sendReceiveChannel
    subscribedTopicMsgChannel
    contextMsgChannel
    contextQueueLock
    function MqttClient(
      channel::MqttNetworkChannel = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883),
      lastCommTime::Int = 0,
      isRunning::Bool = true,
      session::MqttSession = MqttSession(String(""), Dict()),
      clientId::String = String(""),
      cleanSession::Bool = true,
      will::WillOptions = WillOptions(),
      willFlag::Bool = false,
      keepAlivePeriod::Int = 0,
      staticMsgId::UInt16 = UInt16(1),
      sendReceiveChannel::Channel{Any} = Channel{Any}(1),
      subscribedTopicMsgChannel::Channel{ReceivedMessage} = Channel{ReceivedMessage}(10),
      contextMsgChannel::Channel{Any} = Channel{Any}(30),
      contextQueueLock = Threads.Mutex())

      this = new()
      this.channel = channel
      this.lastCommTime = lastCommTime
      this.isRunning = isRunning
      this.session = session
      this.clientId = clientId
      this.cleanSession = cleanSession
      this.will = will
      this.willFlag = willFlag
      this.keepAlivePeriod = keepAlivePeriod
      this.staticMsgId = staticMsgId
      this.sendReceiveChannel = sendReceiveChannel
      this.subscribedTopicMsgChannel = subscribedTopicMsgChannel
      this.contextMsgChannel = contextMsgChannel
      this.contextQueueLock = contextQueueLock
      return this
    end
end
