# MQTT Client

include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")


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

    #TODO: msg queues & event handlers

end
MqttClient() = MqttClient(clientId::String, isConnected::Bool, cleanSession::Bool, WillOptions(), false, MqttNetworkChannel(), PROTOCOL_VERSION_V3_1_1, MqttSession(String(""), Dict()), 60, 0, false )


function MqttConnect(client::MqttClient, clientId::String, username::String, password::String;
    will::WillOptions = WillOptions(false, AT_MOST_ONCE, String("aWillTopic"), String("aWillMessage")),
    willFlag::Bool = false)

    msgConnect = MqttMsgConnect(client, clientId, username, password, will, willFlag, client.cleanSession, client.keepAlivePeriod, client.protocolVersion, 0)

    try
        # TODO: connect to broker
    catch err
        showerror(STDOUT, err, backtrace()); println()
    end

    client.lastCommTime = 0
    client.isRunning = true

    # TODO: start receiving thread

    connack::MqttMsgConnack = SendReceive(msgConnect)
    # if connection accepted, start keep alive timer and
    if connack.returnCode == CONN_ACCEPTED

        # set all client properties
        client.clientId = clientId
        client.cleanSession = cleanSession
        client.willFlag = willFlag
        client.willOptions = willOptions

        client.keepAlivePeriod = keepAlivePeriod * 1000 # convert in ms

        # restore previous session
        # this.RestoreSession();

        #keep alive period equals zero means turning off keep alive mechanism
        if (this.keepAlivePeriod != 0)
            # start thread for sending keep alive message to the broker
            # Fx.StartThread(this.KeepAliveThread);
        end

        # start thread for raising received message event from broker
        # Fx.StartThread(this.DispatchEventThread);

        # start thread for handling inflight messages queue to broker asynchronously (publish and acknowledge)
        # Fx.StartThread(this.ProcessInflightThread);

        client.isConnected = true;
    end

    return connack.returnCode;

end #function

function SendReceive(msgConnect)
    connack::MqttMsgConnack = MqttMsgConnack()

    return connack
end

function MqttDisconnect()

end

function MqttSubscribe()

end

function MqttUnsubscribe()

end

function MqttPublish()

end
