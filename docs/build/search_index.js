var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#JlMQTT.jl-Documentation-1",
    "page": "Home",
    "title": "JlMQTT.jl Documentation",
    "category": "section",
    "text": "Pages = [\"index.md\", \"publicinterface.md\", \"networking.md\", \"messages.md\"]\nDepth = 3"
},

{
    "location": "index.html#Introduction-1",
    "page": "Home",
    "title": "Introduction",
    "category": "section",
    "text": "JlMQTT is a MQTT client written in Julia programming language.Message Queue Telemetry Transport is a light weight messaging protocol that enables embedded devices with limited resources to perform asynchronous communication on a constrained network.MQTT protocol is based on publish/subscribe pattern so that a client can subscribe to one or more topics and receive message that other clients publish on these topics.For all information about MQTT protocol, plsease visit official web site http://mqtt.org/ ."
},

{
    "location": "index.html#Getting-Started-1",
    "page": "Home",
    "title": "Getting Started",
    "category": "section",
    "text": "To start this MQTT program, run JMqttImplementationTest.jl"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "To install JlMQTT.jl run this on Julia \"Atom\" IDE and use a program such as Wireshark to show, for example, the publish and subscribe packets being sent across the connection. "
},

{
    "location": "publicinterface.html#",
    "page": "Public Interface",
    "title": "Public Interface",
    "category": "page",
    "text": ""
},

{
    "location": "publicinterface.html#JlMQTT.MqttConnect-Tuple{JlMQTT.MqttClient,String}",
    "page": "Public Interface",
    "title": "JlMQTT.MqttConnect",
    "category": "Method",
    "text": "JlMQTT.MqttConnect(client::JlMQTT.MqttClient, clientId::String)\n\nSends CONNECT message to broker and receives CONNACK message from broker.\n\nParameters:\n\nclient - [in] JlMQTT.MqttClient\n\nclientId - [in] client identifier of type String\n\nusername - [optional] type String\n\npassword - [optional] type String\n\nwill - [optional] JlMQTT.WillOptions\n\nwillFlag - [optional] will flag of type Boolean\n\ncleanSession - [optional] clean session flag of type Boolean\n\nReturns:\n\n[out] return code received from broker CONNACK message\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.MqttDisconnect-Tuple{JlMQTT.MqttClient}",
    "page": "Public Interface",
    "title": "JlMQTT.MqttDisconnect",
    "category": "Method",
    "text": "JlMQTT.MqttDisconnect(client::JlMQTT.MqttClient)\n\nSends DISCONNECT message to broker and closes all open channels.\n\nParameters:\n\nclient - [in] JlMQTT.MqttClient\n\nReturns:\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.MqttSubscribe-Tuple{JlMQTT.MqttClient,Array{String,1},Array{UInt8,1}}",
    "page": "Public Interface",
    "title": "JlMQTT.MqttSubscribe",
    "category": "Method",
    "text": "JlMQTT.MqttSubscribe(client::JlMQTT.MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})\n\nSends SUBSCRIBE message to broker and returns SUBSCRIBE message identifier.\n\nParameters:\n\nclient - [in] JlMQTT.MqttClient\n\ntopics - [in] collection of topics of type Vector{String}\n\nqosLevels - [in] collection of QOS LEVELS of type Vector{UInt8}\n\nReturns:\n\n[out] SUBSCRIBE message identifier\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.MqttUnsubscribe-Tuple{JlMQTT.MqttClient,Array{String,1}}",
    "page": "Public Interface",
    "title": "JlMQTT.MqttUnsubscribe",
    "category": "Method",
    "text": "JlMQTT.MqttUnsubscribe(client::JlMQTT.MqttClient, topics::Vector{String})\n\nSends UNSUBSCRIBE message to broker and returns UNSUBSCRIBE message identifier.\n\nParameters:\n\nclient - [in] JlMQTT.MqttClient\n\ntopics - [in] collection of topics of type Vector{String}\n\nReturns:\n\n[out] UNSUBSCRIBE message identifier\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.MqttPublish-Tuple{JlMQTT.MqttClient,String,Array{UInt8,1}}",
    "page": "Public Interface",
    "title": "JlMQTT.MqttPublish",
    "category": "Method",
    "text": "JlMQTT.MqttPublish(client::JlMQTT.MqttClient, topic::String, message::Vector{UInt8}; qos::JlMQTT.QosLevel = AT_MOST_ONCE, retain::Bool = false)\n\nSends PUBLISH message to broker and returns PUBLISH message identifier.\n\nParameters:\n\nclient - [in] JlMQTT.MqttClient\n\ntopic - [in] publish to topic of type Vector{String}\n\nmessage - [in] message to publish of type Vector{UInt8}\n\nqos - [optional] message QoS level\n\nretain - [optional] retain flag\n\nReturns:\n\n[out] SUBSCRIBE message identifier\n\n\n\n"
},

{
    "location": "publicinterface.html#Public-Interface-1",
    "page": "Public Interface",
    "title": "Public Interface",
    "category": "section",
    "text": "This section documents the public interface that provides an abstraction layer on MQTT messages and framing.JlMQTT.MqttConnect(client::JlMQTT.MqttClient, clientId::String)\nJlMQTT.MqttDisconnect(client::JlMQTT.MqttClient)\nJlMQTT.MqttSubscribe(client::JlMQTT.MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})\nJlMQTT.MqttUnsubscribe(client::JlMQTT.MqttClient, topics::Vector{String})\nJlMQTT.MqttPublish(client::JlMQTT.MqttClient, topic::String, message::Vector{UInt8}; qos::JlMQTT.QosLevel = AT_MOST_ONCE, retain::Bool = false)"
},

{
    "location": "publicinterface.html#JlMQTT.MqttClient",
    "page": "Public Interface",
    "title": "JlMQTT.MqttClient",
    "category": "Type",
    "text": "JlMQTT.MqttClient\n\nRepresentation of a MQTT Client which provides a JlMQTT.MqttNetworkChannel to a broker.\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.MqttClientConstructor",
    "page": "Public Interface",
    "title": "JlMQTT.MqttClientConstructor",
    "category": "Function",
    "text": "JlMQTT.MqttClientConstructor()\n\nConstructor for JlMQTT.MqttClient.\n\nParameters:\n\nchannel - [in] JlMQTT.MqttNetworkChannel\n\nReturns:\n\n[out] instance of JlMQTT.MqttClient\n\n\n\n"
},

{
    "location": "publicinterface.html#JlMQTT.WillOptions",
    "page": "Public Interface",
    "title": "JlMQTT.WillOptions",
    "category": "Type",
    "text": "JlMQTT.WillOptions\n\nRepresents the Last Will and Testament information.\n\n\n\n"
},

{
    "location": "publicinterface.html#Types-1",
    "page": "Public Interface",
    "title": "Types",
    "category": "section",
    "text": "JlMQTT.MqttClient\nJlMQTT.MqttClientConstructor\nJlMQTT.WillOptions"
},

{
    "location": "networking.html#",
    "page": "Networking",
    "title": "Networking",
    "category": "page",
    "text": ""
},

{
    "location": "networking.html#JlMQTT.Connect-Tuple{JlMQTT.MqttNetworkChannel}",
    "page": "Networking",
    "title": "JlMQTT.Connect",
    "category": "Method",
    "text": "JlMQTT.Connect(network::JlMQTT.MqttNetworkChannel)\n\nConnects to a broker.\n\nParameters:\n\nnetwork - [in] JlMQTT.MqttNetworkChannel\n\n\n\n"
},

{
    "location": "networking.html#JlMQTT.Close-Tuple{JlMQTT.MqttNetworkChannel}",
    "page": "Networking",
    "title": "JlMQTT.Close",
    "category": "Method",
    "text": "JlMQTT.Close(network::JlMQTT.MqttNetworkChannel)\n\nCloses connection to a broker.\n\nParameters:\n\nnetwork - [in] JlMQTT.MqttNetworkChannel\n\n\n\n"
},

{
    "location": "networking.html#JlMQTT.Write-Tuple{JlMQTT.MqttNetworkChannel,Array{UInt8,1}}",
    "page": "Networking",
    "title": "JlMQTT.Write",
    "category": "Method",
    "text": "JlMQTT.Write(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})\n\nSends buffer::Vector{UInt8} to a broker.\n\nParameters:\n\nnetwork - [in] JlMQTT.MqttNetworkChannel\n\nbuffer - [in] Vector{UInt8}\n\n\n\n"
},

{
    "location": "networking.html#JlMQTT.Read-Tuple{JlMQTT.MqttNetworkChannel,Array{UInt8,1}}",
    "page": "Networking",
    "title": "JlMQTT.Read",
    "category": "Method",
    "text": "JlMQTT.Read(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})\n\nReceives buffer::Vector{UInt8} from a broker.\n\nParameters:\n\nnetwork - [in] JlMQTT.MqttNetworkChannel\n\nbuffer - [in] Vector{UInt8}\n\nReturns:\n\n[out] returns the number of read bytes\n\n\n\n"
},

{
    "location": "networking.html#Networking-1",
    "page": "Networking",
    "title": "Networking",
    "category": "section",
    "text": "This section documents the interface and types needed to connect with a broker.JlMQTT.Connect(network::JlMQTT.MqttNetworkChannel)\nJlMQTT.Close(network::JlMQTT.MqttNetworkChannel)\nJlMQTT.Write(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})\nJlMQTT.Read(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})"
},

{
    "location": "networking.html#JlMQTT.MqttNetworkChannel",
    "page": "Networking",
    "title": "JlMQTT.MqttNetworkChannel",
    "category": "Type",
    "text": "JlMQTT.MqttNetworkChannel\n\nRepresentation of a connection to a broker which provides a TCPSocket, remote address as String and remote port as Integer.\n\n\n\n"
},

{
    "location": "networking.html#Types-1",
    "page": "Networking",
    "title": "Types",
    "category": "section",
    "text": "JlMQTT.MqttNetworkChannel"
},

{
    "location": "messages.html#",
    "page": "Messages",
    "title": "Messages",
    "category": "page",
    "text": ""
},

{
    "location": "messages.html#Messages-1",
    "page": "Messages",
    "title": "Messages",
    "category": "section",
    "text": "This section documents the MQTT message types and methods related to message formating and framing."
},

{
    "location": "messages.html#JlMQTT.MqttMsgBase",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgBase",
    "category": "Type",
    "text": "JlMQTT.MqttMsgBase\n\nRepresents the message base with shared values between all MQTT packets.\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgConnect",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgConnect",
    "category": "Type",
    "text": "JlMQTT.MqttMsgConnect\n\nRepresents the CONNECT message. Constructor: JlMQTT.MqttMsgConnectConstructor(clientId::String)\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgConnack",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgConnack",
    "category": "Type",
    "text": "JlMQTT.MqttMsgConnack\n\nRepresents the CONNACK message. Constructor: JlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgContext",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgContext",
    "category": "Type",
    "text": "JlMQTT.MqttMsgContext\n\nA context package which describes the status of a message package.\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgDisconnect",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgDisconnect",
    "category": "Type",
    "text": "JlMQTT.MqttMsgDisconnect\n\nDisconnect package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPingreq",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPingreq",
    "category": "Type",
    "text": "JlMQTT.MqttMsgPingreq\n\nPing request package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPingresp",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPingresp",
    "category": "Type",
    "text": "JlMQTT.MqttMsgPingresp\n\nPing rresponse package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPuback",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPuback",
    "category": "Type",
    "text": "JIMQTT.MqttMsgPuback\n\nMqtt Puback Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPubcomp",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPubcomp",
    "category": "Type",
    "text": "JIMQTT.MqttMsgPubcomp\n\nMqtt Pubcomp Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPublish",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPublish",
    "category": "Type",
    "text": "JIMQTT.MqttMsgPublish\n\nMqtt Publish Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPubrec",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPubrec",
    "category": "Type",
    "text": "JIMQTT.MqttMsgPubrec\n\nMqtt Pubrec Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgPubrel",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgPubrel",
    "category": "Type",
    "text": "JIMQTT.MqttMsgPubrel\n\nMqtt Pubrel Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgSuback",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgSuback",
    "category": "Type",
    "text": "JlMQTT.MqttMsgSuback\n\nSubscribe Acknowledgement Package\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgSubscribe",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgSubscribe",
    "category": "Type",
    "text": "JlMQTT.MqttMsgSubscribe\n\nSubscribe Package \n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgUnsuback",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgUnsuback",
    "category": "Type",
    "text": "JlMQTT.MqttMsgUnsuback\n\nThis is the Unsubscribe Acknowledgement Package \n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgUnsubscribe",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgUnsubscribe",
    "category": "Type",
    "text": "JlMQTT.MqttMsgUnsubscribe\n\nThis is the Unsubscribe Package \n\n\n\n"
},

{
    "location": "messages.html#Types-1",
    "page": "Messages",
    "title": "Types",
    "category": "section",
    "text": "JlMQTT.MqttMsgBase\nJlMQTT.MqttMsgConnect\nJlMQTT.MqttMsgConnack\nJlMQTT.MqttMsgContext\nJlMQTT.MqttMsgDisconnect\nJlMQTT.MqttMsgPingreq\nJlMQTT.MqttMsgPingresp\nJlMQTT.MqttMsgPuback\nJlMQTT.MqttMsgPubcomp\nJlMQTT.MqttMsgPublish\nJlMQTT.MqttMsgPubrec\nJlMQTT.MqttMsgPubrel\nJlMQTT.MqttMsgSuback\nJlMQTT.MqttMsgSubscribe\nJlMQTT.MqttMsgUnsuback\nJlMQTT.MqttMsgUnsubscribe"
},

{
    "location": "messages.html#JlMQTT.MsgType",
    "page": "Messages",
    "title": "JlMQTT.MsgType",
    "category": "Type",
    "text": "JlMQTT.MsgType\n\nEnumeration representing MQTT message types.\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.QosLevel",
    "page": "Messages",
    "title": "JlMQTT.QosLevel",
    "category": "Type",
    "text": "JlMQTT.QosLevels\n\nEnumeration representing MQTT QoS Levels.\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.ConnackCode",
    "page": "Messages",
    "title": "JlMQTT.ConnackCode",
    "category": "Type",
    "text": "JlMQTT.ConnackCode\n\nEnumeration representing MQTT CONNACK return codes.\n\n\n\n"
},

{
    "location": "messages.html#Definitions-1",
    "page": "Messages",
    "title": "Definitions",
    "category": "section",
    "text": "JlMQTT.MsgType\nJlMQTT.QosLevel\nJlMQTT.ConnackCode"
},

{
    "location": "messages.html#JlMQTT.MqttMsgBase-Tuple{JlMQTT.MsgType,UInt16}",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgBase",
    "category": "Method",
    "text": "JlMQTT.MqttMsgBase(msgType::JlMQTT.MsgType, msgId::UInt16)\n\nConstructs a JlMQTT.MqttMsgBase.\n\nParameters:\n\nmsgType - [in] enum JlMQTT.MsgType\n\nmsgId - [in] message identifier of type UInt16\n\nretain - [optional] retain flag of type Boolean\n\ndup - [optional] dup flag of type Boolean\n\nqos - [optional] JlMQTT.QosLevel\n\nReturns:\n\n[out] JlMQTT.MqttMsgBase\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgConnectConstructor-Tuple{String}",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgConnectConstructor",
    "category": "Method",
    "text": "JlMQTT.MqttMsgConnectConstructor(clientId::String)\n\nConstructs a JlMQTT.MqttMsgConnect.\n\nParameters:\n\nclient - JlMQTT.MqttClient\n\nusername - [optional] type String\n\npassword - [optional] type String\n\nwill - [optional] JlMQTT.WillOptions\n\nwillFlag - [optional] will flag of type Boolean\n\ncleanSession - [optional] clean session flag of type Boolean\n\nkeepAlivePeriod - [optional] keep alive time interval of type UInt16\n\nstaticMsgId - [optional] message identifier of type UInt16\n\nReturns:\n\n[out] JlMQTT.MqttMsgConnack\n\n\n\n"
},

{
    "location": "messages.html#JlMQTT.MqttMsgConnackConstructor-Tuple{JlMQTT.ConnackCode,Bool}",
    "page": "Messages",
    "title": "JlMQTT.MqttMsgConnackConstructor",
    "category": "Method",
    "text": "JlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)\n\nConstructs a JlMQTT.MqttMsgConnack.\n\nParameters:\n\nreturnCode - JlMQTT.ConnackCode\n\nsessionPresent - session present flag of type Boolean\n\nReturns:\n\n[out] JlMQTT.MqttMsgConnack\n\n\n\n"
},

{
    "location": "messages.html#Constructors-1",
    "page": "Messages",
    "title": "Constructors",
    "category": "section",
    "text": "JlMQTT.MqttMsgBase(msgType::JlMQTT.MsgType, msgId::UInt16)\nJlMQTT.MqttMsgConnectConstructor(clientId::String)\nJlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)"
},

]}
