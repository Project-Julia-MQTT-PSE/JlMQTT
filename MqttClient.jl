# MQTT Client
using DataStructures
include("Messages/Definitions.jl")
include("MqttNetworkChannel.jl")
include("Messages/MqttMsgConnect.jl")
include("Messages/MqttMsgConnack.jl")
include("Messages/MqttMsgPubcomp.jl")
include("Messages/MqttMsgPingreq.jl")
include("Messages/MqttMsgPingresp.jl")
include("Messages/MqttMsgPublish.jl")
include("Messages/MqttMsgPuback.jl")
include("Messages/MqttMsgPubrec.jl")
include("Messages/MqttMsgContext.jl")
include("Messages/MqttMsgSubscribe.jl")
include("Messages/MqttMsgSuback.jl")
include("Messages/MqttMsgUnsubscribe.jl")
include("Messages/MqttMsgUnsuback.jl")
include("Messages/MqttMsgDisconnect.jl")


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

    staticMsgId::UInt16
    sendReceiveChannel
    msgReceivedChannel
    subscribedTopicMsgChannel
    inflightQueue
    inflightQueueLock
end

MqttClient() = MqttClient(
    PROTOCOL_VERSION_V3_1_1,
    MqttNetworkChannel(TCPSocket(), "141.100.70.71", 1883), # 141.100.70.71:1883 MQTT_Server.fbi.h-da.de
    0,
    false,
    false,
    MqttSession(String(""), Dict()),
    false,
    String(""),
    true,
    WillOptions(),
    false,
    0,
    UInt16(1),
    Channel{Any}(1),
    Channel{Any}(30),
    Channel{Any}(10),
    Channel{Any}(40),
    Threads.Mutex())


#MqttClient() = MqttClient("clientid", false, false, WillOptions(), false, MqttNetworkChannel(), PROTOCOL_VERSION_V3_1_1, MqttSession(String(""), Dict()), 60, 0, false )
#Sending CONNECT Message to broker
function MqttConnect(_client::MqttClient,
  _clientId::String;
  _username::String = "",
  _password::String = "",
  _will::WillOptions = WillOptions(),
  _willFlag::Bool = false,
  _cleanSession::Bool = true,
  _keepAlivePeriode::UInt16 = UInt16(0))
  #Create CONNECT Message
    msgConnect = MqttMsgConnect(_clientId,
    username=_username,
    password=_password,
    will=_will,
    willFlag=_willFlag,
    cleanSession=_cleanSession,
    keepAlivePeriod=_keepAlivePeriode,
    protocolLevel=_client.protocolVersion,
    staticMsgId =_client.staticMsgId)
    _client.staticMsgId

    try
        #Connect to Broker
        Connect(_client.channel)
    catch err
        showerror(STDOUT, err, backtrace()); println()
    end

    _client.lastCommTime = 0
    _client.isRunning = true
    _client.isConnectionClosing = false

    #start receiving thread
    receiveTask() = ReceiveThread(_client)
    t = Task(receiveTask)
    schedule(t)
    Write(_client.channel, Serialize(msgConnect))
    msgReceived = take!(_client.sendReceiveChannel)
    # if connection accepted, start keep alive timer and
    if msgReceived.returnCode == CONN_ACCEPTED

        # set all client properties
        _client.clientId = _clientId
        _client.cleanSession = _cleanSession
        _client.willFlag = _willFlag
        _client.will = _will

        _client.keepAlivePeriod = KEEP_ALIVE_PERIOD_DEFAULT * 1000 # convert in ms

        # restore previous session
        # this.RestoreSession();

        #keep alive period equals zero means turning off keep alive mechanism
        if (_client.keepAlivePeriod != 0)
            # start thread for sending keep alive message to the broker
            # Fx.StartThread(this.KeepAliveThread);
            keepAliveTask = KeepAliveThread(_client)
            k = Task(KeepAliveThread)
            schedule(k)
        end

        # start thread for raising received message event from broker
        # Fx.StartThread(this.DispatchEventThread);

        # start thread for handling inflight messages queue to broker asynchronously (publish and acknowledge)
        # Fx.StartThread(this.ProcessInflightThread);

        _client.isConnected = true;
    end
    return msgReceived.returnCode;
end #function

function RestoreSession()

end

function MqttDisconnect(client::MqttClient)
  disconnect::MqttMsgDisconnect = MqttMsgDisconnect()
  Write(client.channel, Serialize(disconnect))
end
#Subscribe to message Topics
function MqttSubscribe(client::MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})
  subscribe::MqttMsgSubscribe = MqttMsgSubscribe(MqttMsgBase(SUBSCRIBE_TYPE, client.staticMsgId), topics, qosLevels)
  client.staticMsgId += 1
  Write(client.channel, Serialize(subscribe))
end

function MqttUnsubscribe(client::MqttClient, topics::Vector{String})
  unsubscribe::MqttMsgUnsubscribe = MqttMsgUnsubscribe(MqttMsgBase(UNSUBSCRIBE_TYPE, client.staticMsgId), topics)
  client.staticMsgId += 1
  Write(client.channel, Serialize(unsubscribe))
end

function MqttPublish(client::MqttClient, topic::String, message::Vector{UInt8}; qos::QosLevel = AT_MOST_ONCE, retain::Bool = false)
  publish::MqttMsgPublish = MqttMsgPublish(topic, message=message, base=MqttMsgBase(PUBLISH_TYPE, client.staticMsgId, retain=retain, dup=false, qos=qos))
  client.staticMsgId += 1
  Write(client.channel, Serialize(publish))
end

# Keep Alive thread
function KeepAliveThread(client::MqttClient)
  @async while true
    ping::MqttMsgPingreq = MqttMsgPingreq()

    Write(client.channel, Serialize(ping))
    msgReceived = take!(client.sendReceiveChannel)

    sleep(20)
  end
end

#Enquue a message into the inflight queue
function EnqueueInflight(msg, flow::MqttMsgFlow, client::MqttClient)
    enqueue::Bool = true

    #if it's a PUBLISH MESSAGE with Qos2
    msgType = ((msg.msgBase.fixedHeader & MSG_TYPE_MASK) >> MSG_TYPE_OFFSET)::UInt8
    if msgType == PUBLISH_TYPE && msg.msgBase.qos == EXACTLY_ONCE

        #lock(inflightQueueLock)

        # if it is a PUBLISH message already received (it is in the inflight queue), the publisher
        # re-sent it because it didn't received the PUBREC. In this case, we have to re-send PUBREC

        # NOTE : I need to find on message id and flow because the broker could be publish/received
        #        to/from client and message id could be the same (one tracked by broker and the other by client)
        msgContext = FindPublishInInflightQueue(msg.msgId, ToAcknowledge)
        if msgContext != 0
          msgContext.state = QueuedQos2
          msgContext.flow = ToAcknowledge
          enqueue = false
        end

        #unlock(inflightQueueLock)
    end # if

    if enqueue
        state::MqttMsgState = QueuedQos0

        # based on QoS level, the messages flow between broker and client changes
        if msg.msgBase.qos == AT_MOST_ONCE
            state = QueuedQos0
        elseif msg.msgBase.qos == AT_LEAST_ONCE
            state = QueuedQos1
        elseif msg.msgBase.qos == EXACTLY_ONCE
            state = QueuedQos2
        end
    end

    # [v3.1.1] SUBSCRIBE and UNSUBSCRIBE aren't "officially" QOS = 1
    #          so QueuedQos1 state isn't valid for them
    if msgType == SUBSCRIBE_TYPE
        state = SendSubscribe
    elseif (msgType == UNSUBSCRIBE_TYPE)
        state = SendUnsubscribe
    end

    newMsgContext::MqttMsgContext = MqttMsgContext(msg.msgBase, state, flow, 0, 0)

    #lock(inflightQueueLock)

    # check number of messages inside inflight queue
    enqueue = length(client.inflightQueue) < typemax(UInt16) # TODO: set max queue size elsewhere
    if enqueue
        enqueue!(client.inflightQueue, newMsgContext)

        if msgType == PUBLISH_TYPE
            # to publish and QoS level 1 or 2
            if (newMsgContext.flow == ToPublish) && ((msg.msgBase.qos == AT_LEAST_ONCE) || (msg.msgBase.qos == EXACTLY_ONCE))

                if (client.session != null)
                    enqueue!(client.session.InflightMessages, newMsgContext)
                    #client.session.inFlightMessages.Add(msgContext.Key, msgContext);
                end
                # to acknowledge and QoS level 2
            elseif (newMsgContext.flow == ToAcknowledge) && (msg.msgBase.qos == EXACTLY_ONCE)
                if (this.session != null)
                    enqueue!(client.session.InflightMessages, newMsgContext)
                    #client.session.inFlightMessages.Add(msgContext.Key, msgContext);
                end
            end
        end
    end

    #unlock(inflightQueueLock)

    return enqueue
end

#Enque a message into internal queue
function EnqueueInternal(msg::MqttMsgBase, client::MqttClient)
  enqueueNeeded::Bool = true
  #If PUBREL Message
  if (msg.fixedHeader >> MSG_TYPE_OFFSET) == PUBREL_TYPE
    lock(inflightQueueLock)
    #If corresponding PUBLISH isn't in the inflight queue, it means it was alreadyprocessed
    #and PUBREL was already received and we send PUBCOMP, but PUBCOMB didn't reached Broker
    #Only re-send PUBCOMP
    msgContext = FindPublishInInflightQueue(msg.msgId, ToAcknowledge)
    if msgContext == 0
      pubcomp::MqttMsgPubcomp = MqttMsgPubcomp()
      pubcomp.msgBase.msgId = msg.msgId
      Write(client.channel, Serialize(pubcomp))
      enqueueNeeded = false
    end
    unlock(inflightQueueLock)
    #If PUBCOM Message
  elseif (msg.fixedHeader >> MSG_TYPE_OFFSET) == PUBCOMP_TYPE
    lock(inflightQueueLock)
    #if corresponding PUBLISH isn't in the inflight queue, it means
    #We sent PUBLISH message, sent PUBREL (after receiving PUBREC)
    #and alread received PUBCOMP, but publisher didn't receive PUBREL so it re-sent PUBCOMP. We onlc ignore this PUBCOMP
    msgContext = FindPublishInInflightQueue(msg.msgId, ToPublish)
    if msgContext == 0
      enqueueNeeded = false
    end
    unlock(inflightQueueLock)
  elseif (msg.fixedHeader >> MSG_TYPE_OFFSET) == PUBREC_TYPE
    lock(inflightQueueLock)
    #if corresponding PUBLISH isn't in the inflight queue, it means
    #that we sent PUBLISH several times but broker didn't send PUBREC in times
    #the publish is failed and we only need to ignore this PUBREX
    msgContext = FindPublishInInflightQueue(msg.msgId, ToPublish)
    if msgContext == 0
      enqueueNeeded = false
    end
    unlock(inflightQueueLock)
  end
  if enqueueNeeded == true
    lock(internalQueueLock)
    enqueue!(internalQueue, msg)
    unlock(internalQueueLock)
  end
end

#Search is PUBLISH message is in inflightQueue, if yes return it else return null
function FindPublishInInflightQueue(messageId::UInt8, flow::MqttMsgFlow)
  msgIte = start(inflightQueue)
  while !done(inflightQueue, msgIte)
    (i, msgIte) = next(inflightQueue, msgIte)
    if i.message.msgBase.msgId == messageId && (i.message.fixedHeader >> MSG_TYPE_OFFSET) == PUBLISH_TYPE && i.flow == flow
      return i
    end
  end
  return 0
end

#Async Task which waits for incoming message
#Parse them together, or throw error for wrong message
function ReceiveThread(client::MqttClient)
  readBytes::Int = 0
  fixedHeaderFirstByte = UInt8[0x00]
  msgType::UInt8 = 0x00

  @async while client.isRunning
    readBytes = Read(client.channel, fixedHeaderFirstByte)
    if readBytes > 0x00
      msgType = ((fixedHeaderFirstByte[1] & MSG_TYPE_MASK) >> MSG_TYPE_OFFSET)::UInt8
      println(msgType)
      if msgType == UInt8(CONNECT_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (CONNECT)"))
      elseif msgType == UInt8(CONNACK_TYPE)
        println("CONNACK MESSAGE RECEIVED!")
        put!(client.sendReceiveChannel, MsgConnackParse(client.channel))
      elseif msgType == UInt8(PINGREQ_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (PINGREQ)"))
      elseif msgType == UInt8(PINGRESP_TYPE)
        println("PINGRESP MESSAGE RECEIVED!")
        put!((client.sendReceiveChannel), MsgPingrespParse(client.channel))
      elseif msgType == UInt8(SUBSCRIBE_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (SUBSCRIBE)"))
      elseif msgType == UInt8(SUBACK_TYPE)
        println("SUBACK MESSAGE RECEIVED!")
        put!((client.msgReceivedChannel), MsgSubackParse(client.channel))
      elseif msgType == UInt8(PUBLISH_TYPE)
        println("PUBLISH MESSAGE RECEIVED!")
        put!(client.subscribedTopicMsgChannel, MsgPublishParse(client.channel, fixedHeaderFirstByte[1]))
      elseif msgType == UInt8(PUBACK_TYPE)
        println("PUBACK MESSAGE RECEIVED!")
        put!((client.msgReceivedChannel), MsgPubackParse(client.channel))
      elseif msgType == UInt8(PUBREC_TYPE)
        println("PUBREC MESSAGE RECEIVED!")
        put!((client.msgReceivedChannel), MsgPubrecParse(client.channel))
      elseif msgType == UInt8(PUBREL_TYPE)
        println("PUBREL MESSAGE RECEIVED!")
      elseif msgType == UInt8(PUBCOMP_TYPE)
        println("PUBCOMP MESSAGE RECEIVED!")
      elseif msgType == UInt8(PUBCOMP_TYPE)
        println("PUBCOMP MESSAGE RECEIVED!")
      elseif msgType == UInt8(UNSUBSCRIBE_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (UNSUBSCRIBE)"))
      elseif msgType == UInt8(UNSUBACK_TYPE)
        println("UNSUBACK MESSAGE RECEIVED!")
      put!((client.msgReceivedChannel), MsgUnsubackParse(client.channel))
      elseif msgType == UInt8(DISCONNECT_TYPE)
        throw(ErrorException("WRONG BROKER MESSAGE! (DISCONNECT)"))
      else
        throw(ErrorException("WRONG BROKER MESSAGE! (UNKNOWN)"))
      end
    end
    #try
    #catch err
    #  showerror(STDOUT, err, backtrace()); println()
    #end
  end
end

function DispatchEventThread()
end

function ProcessInflightThread(client::MqttClient)

    msgContext::MqttMsgContext = 0
    msgInflight::MqttPacket = 0
    acknowledge::bool = false
    msgReceivedProcessed::bool = false

    @async while client.isRunning
        if client.isRunning
            #lock(inflightQueueLock)
            msgReceivedProcessed = false
            acknowledge = false

            count::Int = length(client.inflightQueue)

            while count > 0
                count -= 1
                acknowledge = false
                if !client.isRunning break end

                #msgContext::MqttMsgContext =
            end
        end
    end
end

function test()

    msg::Nullable{MqttPacket} = Nullable{MqttPacket}()

    if isnull(msg)
        println("1 $msg")
    end

    msg::MqttPacket = MqttMsgConnect(MqttMsgBase(),"123", "user", "pw", WillOptions(false, AT_MOST_ONCE, String(""), String("")), false, false, KEEP_ALIVE_PERIOD_DEFAULT, PROTOCOL_VERSION_V3_1_1, 0)

    println("2 $msg")
end

"""
m=MqttClient()
MqttConnect(m, "clientid")
"""
