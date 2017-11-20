# MQTT Client

include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("Messages/MqttMsgConnack.jl")

const RECEIVE_THREAD_NAME = "ReceiveThread";
const RECEIVE_EVENT_THREAD_NAME = "DispatchEventThread";
const PROCESS_INFLIGHT_THREAD_NAME = "ProcessInflightThread";
const KEEP_ALIVE_THREAD = "KeepAliveThread";

mutable struct MqttSession
    clientId::String
    inFlightMessages::Dict
end

mutable struct MqttClient
    clientId::String
    isConnected::Bool
    cleanSession::Bool

    will::WillOptions
    willFlag::Bool

    broker::MqttNetworkChannel
    protocolVersion::MqttVersion
    session::MqttSession
    keepAlivePeriod::Int
    lastCommTime::Int #Last communication time
    isRunning::Bool #Thread status

    # inflight messages queue
    inflightQueue
    # internal queue for received messages about inflight messages
    internalQueue
    # internal queue for dispatching events
    eventQueue

    # event handlers
    MqttMsgPublishReceiveEventHandler
    MqttMsgPublishedEventHandler
    MqttMsgSubscribedEventHandler
    MqttMsgUnsubscribedEventHandler
    ConnectionClosedEventHandler
end
MqttClient() = MqttClient("clientid", false, false, WillOptions(), false, MqttNetworkChannel(), PROTOCOL_VERSION_V3_1_1, MqttSession(String(""), Dict()), 60, 0, false )


function MqttConnect(client::MqttClient, clientId::String;
    username::String = "",
    password::String = "",
    will::WillOptions = WillOptions(),
    willFlag::Bool = false,
    cleanSession::Bool = false)

    msgConnect = MqttMsgConnect(clientId)

    try
        # TODO: connect to broker
        client.broker = MqttNetworkChannel()

        Open(client.broker)
        println("open conn")


    catch err
        showerror(STDOUT, err, backtrace()); println()
    end

    client.lastCommTime = 0
    client.isRunning = true

    # TODO: start receiving thread
    receiveTask = Task(ReceiveThread)
    schedule(receiveTask)



    connack::MqttMsgConnack = SendReceive(msgConnect)
    # if connection accepted, start keep alive timer and
    if connack.returnCode == CONN_ACCEPTED

        # set all client properties
        client.clientId = clientId
        client.cleanSession = cleanSession
        client.willFlag = willFlag
        client.will = will

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
        println(client)
    end

    return connack.returnCode;

end #function

function SendReceive(msgConnect::MqttMsgConnect, broker::TCPSocket)
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

function ReceiveThread()
end

function DispatchEventThread()
end

function ProcessInflightThread()
end

"""
m=MqttClient()
MqttConnect(m, "clientid")
"""
