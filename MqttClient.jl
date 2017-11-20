# MQTT Client
include("Messages/Definitions.jl")
include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("Messages/MqttMsgConnack.jl")


const RECEIVE_THREAD_NAME = "ReceiveThread";
const RECEIVE_EVENT_THREAD_NAME = "DispatchEventThread";
const PROCESS_INFLIGHT_THREAD_NAME = "ProcessInflightThread";
const KEEP_ALIVE_THREAD = "KeepAliveThread";

using DataStructures

mutable struct MqttSession
    clientId::String
    inFlightMessages::Dict
end

mutable struct MqttClient

    protocolVersion::MqttVersion
    channel::MqttNetworkChannel

    lastCommTime::Int
    isRunning::Bool
    isConnectionClosing::Bool
    session::MqttSession

    isConnected::Bool
    clientId::String
    cleanSession::Bool
    will::WillOptions
    willFlag::Bool
    keepAlivePeriod::Int



    # inflight messages queue
    inflightQueue
    # internal queue for received messages about inflight messages
    internalQueue
    # internal queue for dispatching events
    eventQueue

    # event handlers
    #MqttMsgPublishReceiveEventHandler
    #MqttMsgPublishedEventHandler
    #MqttMsgSubscribedEventHandler
    #MqttMsgUnsubscribedEventHandler
    #ConnectionClosedEventHandler
    function MqttClient(
      channel::MqttNetworkChannel = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883),
      protocolVersion::MqttVersion = PROTOCOL_VERSION_V3_1_1,
      lastCommTime::Int = 0,
      isRunning::Bool = false,
      isConnectionClosing::Bool = false,
      session::MqttSession = MqttSession(String(""), Dict()),
      isConnected::Bool = false,
      clientId::String = String(""),
      cleanSession::Bool = false,
      will::WillOptions = WillOptions(),
      willFlag::Bool = false,
      keepAlivePeriod::Int = 0,
      inflightQueue = Queue(Int),
      internalQueue = Queue(Int),
      eventQueue = Queue(Int))

      this = new()
      this.protocolVersion = protocolVersion
      this.channel = channel
      this.lastCommTime = lastCommTime
      this.isRunning = isRunning
      this.isConnectionClosing = isConnectionClosing
      this.session = session
      this.isConnected = isConnected
      this.clientId = clientId
      this.cleanSession = cleanSession
      this.will = will
      this.willFlag = willFlag
      this.keepAlivePeriod = keepAlivePeriod
      this.inflightQueue = inflightQueue
      this.internalQueue = internalQueue
      this.eventQueue = eventQueue
      return this
    end
end
#MqttClient() = MqttClient("clientid", false, false, WillOptions(), false, MqttNetworkChannel(), PROTOCOL_VERSION_V3_1_1, MqttSession(String(""), Dict()), 60, 0, false )
#Sending CONNECT Message to broker
function MqttConnect(_client::MqttClient,
  _clientId::String;
  _username::String = "",
  _password::String = "",
  _will::WillOptions = WillOptions(),
  _willFlag::Bool = false,
  _cleanSession::Bool = false,
  _keepAlivePeriode::Int = 0)

  #Create CONNECT Message
    msgConnect = MqttMsgConnect(_clientId,
    username=_username,
    password=_password,
    will=_will,
    willFlag=_willFlag,
    cleanSession=_cleanSession,
    keepAlivePeriod=_keepAlivePeriode,
    protocolLevel=_client.protocolVersion)

    try
        #Connect to Broker
        Connect(_client.channel)
    catch err
        showerror(STDOUT, err, backtrace()); println()
    end

    _client.lastCommTime = 0
    _client.isRunning = true
    _client.isConnectionClosing = false
    # TODO: start receiving thread
    receiveTask = Task(ReceiveThread(_client))
    schedule(receiveTask)

    connack::MqttMsgConnack = SendReceive(msgConnect, _client.channel)
    # if connection accepted, start keep alive timer and
    if connack.returnCode == CONN_ACCEPTED

        # set all client properties
        client.clientId = _clientId
        client.cleanSession = _cleanSession
        client.willFlag = _willFlag
        client.will = _will

        client.keepAlivePeriod = KEEP_ALIVE_PERIOD_DEFAULT * 1000 # convert in ms

        # restore previous session
        # this.RestoreSession();

        #keep alive period equals zero means turning off keep alive mechanism
        if (client.keepAlivePeriod != 0)
            # start thread for sending keep alive message to the broker
            # Fx.StartThread(this.KeepAliveThread);
        end

        # start thread for raising received message event from broker
        # Fx.StartThread(this.DispatchEventThread);

        # start thread for handling inflight messages queue to broker asynchronously (publish and acknowledge)
        # Fx.StartThread(this.ProcessInflightThread);

        client.isConnected = true;
    end

    return connack;

end #function

function SendReceive(msgConnect::MqttMsgConnect, channel::MqttNetworkChannel; timeout::Int = MQTT_DEFAULT_TIMEOUT)
  #reset handle before sending TODO
  try
    Write(channel, Serialize(msgConnect))
  catch err
    showerror(STDOUT, err, backtrace()); println()
  end

    connack::MqttMsgConnack = MqttMsgConnack()


    return connack
end

function RestoreSession()

end

function MqttDisconnect()

end

function MqttSubscribe()

end

function MqttUnsubscribe()

end

function MqttPublish()

end

# threads
function KeepAliveThread()
end

function ReceiveThread(client::MqttClient)
  readBytes::Int = 0
  fixedHeaderFirstByte = UInt8[0x00]
  msgType::UInt8 = 0x00

  @async while true
    try
      readBytes = Read(client.channel, fixedHeaderFirstByte)
      if readBytes > 0x00
        msgType = ((fixedHeaderFirstByte[1] & MSG_TYPE_MASK) >> MSG_TYPE_OFFSET)::UInt8
        if msgType == UInt8(CONNACK_TYPE)
          println("CONNACK MESSAGE RECEIVED!")
        end
      end
    catch err
      showerror(STDOUT, err, backtrace()); println()
    end
  end
end

function DispatchEventThread()
end

function ProcessInflightThread()
end

"""
m=MqttClient()
MqttConnect(m, "clientid")
"""
