include("Messages/Definitions.jl")
include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("Messages/MqttMsgConnack.jl")
include("Messages/MqttMsgPubcomp.jl")
include("Messages/MqttMsgPublish.jl")
include("Messages/MqttMsgPuback.jl")
include("Messages/MqttMsgPubrec.jl")
include("Messages/MqttMsgPubrel.jl")
include("Messages/MqttMsgContext.jl")
include("Messages/MqttMsgSubscribe.jl")
include("Messages/MqttMsgSuback.jl")
include("Messages/MqttMsgUnsubscribe.jl")
include("Messages/MqttMsgUnsuback.jl")
include("Messages/MqttMsgDisconnect.jl")
include("ReceivedMessage.jl")
include("Backend/MqttThreads.jl")

#MqttClient() = MqttClient("clientid", false, false, WillOptions(), false, MqttNetworkChannel(), PROTOCOL_VERSION_V3_1_1, MqttSession(String(""), Dict()), 60, 0, false )
#Sending CONNECT Message to broker
function MqttConnect(_client::MqttClient,
  _clientId::String;
  _username::String = "",
  _password::String = "",
  _will::WillOptions = WillOptions(false, AT_MOST_ONCE, String(""), String("")),
  _willFlag::Bool = false,
  _cleanSession::Bool = true)
  #Create CONNECT Message
    msgConnect = MqttMsgConnectConstructor(_clientId,
    username=_username,
    password=_password,
    will=_will,
    willFlag=_willFlag,
    cleanSession=_cleanSession,
    keepAlivePeriod=_client.keepAlivePeriod,
    staticMsgId = _client.staticMsgId)

    _client.staticMsgId += 1

    try
        #Connect to Broker
        Connect(_client.channel)
    catch err
        showerror(STDOUT, err, backtrace()); println()
    end
    _client.lastCommTime = 0
    _client.isRunning = true
    #start receiving thread
    receiveTask() = ReceiveThread(_client)
    t = Task(receiveTask)
    schedule(t)
    Write(_client.channel, Serialize(msgConnect))
    msgReceived = take!(_client.sendReceiveChannel)
    # if connection accepted, start keep alive timer and
    if msgReceived.returnCode == CONN_ACCEPTED
        #keep alive period equals zero means turning off keep alive mechanism
        if (_client.keepAlivePeriod != 0)
            # start thread for sending keep alive message to the broker
          keepAliveTask() = KeepAliveThread(_client)
          k = Task(keepAliveTask)
          schedule(k)
          contextKeepAliveTask() = KeepAliveContextChannelThread(_client)
          c = Task(contextKeepAliveTask)
          schedule(c)
        end
    else
      _client.isRunning = false
      for i in (client.contextMsgChannel, client.sendReceiveChannel, client.subscribedTopicMsgChannel)
        close(i)
      end
    end
    return msgReceived.returnCode;
end

#Send the Disconnect Package to the Broker, and set isRunning = false
function MqttDisconnect(client::MqttClient)
  Write(client.channel, Serialize(MqttMsgDisconnectConstructor()))
  client.isRunning = false
  for i in (client.contextMsgChannel, client.sendReceiveChannel, client.subscribedTopicMsgChannel)
    close(i)
  end
end

#Send Subscribe package and enque package into contextMsgChannel for processing
function MqttSubscribe(client::MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})
  subscribe::MqttMsgSubscribe = MqttMsgSubscribeConstructor(MqttMsgBase(SUBSCRIBE_TYPE, client.staticMsgId), topics, qosLevels)
  client.staticMsgId += 1
  Write(client.channel, Serialize(subscribe))
  put!((client.contextMsgChannel), MqttMsgContextConstructor(subscribe, WaitForSuback, ToAcknowledge))
end

#Send Unsubscribe package and enque package into contextMsgChannel for processing
function MqttUnsubscribe(client::MqttClient, topics::Vector{String})
  unsubscribe::MqttMsgUnsubscribe = MqttMsgUnsubscribeConstructor(MqttMsgBase(UNSUBSCRIBE_TYPE, client.staticMsgId), topics)
  client.staticMsgId += 1
  Write(client.channel, Serialize(unsubscribe))
  put!((client.contextMsgChannel), MqttMsgContextConstructor(unsubscribe, WaitForUnsuback, ToAcknowledge))
end

#Send Publish package and enque package into contextMsgChannel for processing if needed
function MqttPublish(client::MqttClient, topic::String, message::Vector{UInt8}; qos::QosLevel = AT_MOST_ONCE, retain::Bool = false)
  publish::MqttMsgPublish = MqttMsgPublishConstructor(topic, message=message, base=MqttMsgBase(PUBLISH_TYPE, client.staticMsgId, retain=retain, dup=false, qos=qos))
  client.staticMsgId += 1
  Write(client.channel, Serialize(publish))
  if any(qos .== (AT_LEAST_ONCE, EXACTLY_ONCE))
    put!((client.contextMsgChannel), MqttMsgContextConstructor(publish, qos == AT_LEAST_ONCE? WaitForPuback : WaitForPubrec, ToPublish))
  end
end
