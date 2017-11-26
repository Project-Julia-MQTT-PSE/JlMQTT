
include("MqttClient.jl")
include("Messages/Definitions.jl")

client = MqttClient()
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
#MqttSubscribe(client, t, q)
#MqttUnsubscribe(client, t)


#MqttPublish(client, "test/1", m, qos=AT_LEAST_ONCE)
#MqttPublish(client, "test/1", m, qos=EXACTLY_ONCE)
#MqttPublish(client, "test/1", m, qos=AT_LEAST_ONCE)
MqttDisconnect(client)
