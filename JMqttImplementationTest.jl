
include("MqttClient.jl")
include("JlMqtt.jl")
include("Messages/Definitions.jl")
using Base.Test

client = MqttClientConstructor()
@async while true
  println("WAITING FOR INCOMMING MESSAGE FROM SUBSCRIBED CHANNEL")
  println(take!(client.subscribedTopicMsgChannel))
end
MqttConnect(client, String("Client_1"))

t = Array{String}(1)
t[1] = "test/1"
#t[2] = "test/2"

m = Array{UInt8}(1)
#m[1] = "Hello World!"

m = convert(Array{UInt8}, "Hello World!")

q = Array{UInt8}(1)
q[1] = EXACTLY_ONCE
#q[2] = EXACTLY_ONCE
MqttSubscribe(client, t, q)


MqttPublish(client, "test/1", m, qos=AT_LEAST_ONCE)
MqttPublish(client, "test/1", m, qos=EXACTLY_ONCE)
MqttPublish(client, "test/1", m, qos=AT_MOST_ONCE)

#Attempted Connect test
#MqttMsgConnectConstructor(clientId::String)
#client = MqttClientConstructor()
#MqttConnect(client, String("Client_1"))

#msgPacketCheck = [0x10, 0x14, 0x00, 0x04, 0x4d, 0x51, 0x54, 0x54, 0x04, 0x02, 0xff, 0xff, 0x00, 0x08, 0x43, 0x6c, 0x69, 0x65, 0x6e, 0x74, 0x5f, 0x31]
#var check = Serialize(msgConnect::MqttMsgConnect)
#assertEquals(msgPacketCheck, Serialize(msgConnect::MqttMsgConnect))
#assertEquals in Julia?

MqttUnsubscribe(client, t)
MqttDisconnect(client)
