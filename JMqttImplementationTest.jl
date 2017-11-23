
include("MqttClient.jl")

client = MqttClient()
@async while true
  println("WAITING FOR INCOMMING MESSAGE FROM SUBSCRIBED CHANNEL")
  println(take!(client.subscribedTopicMsgChannel))
end
MqttConnect(client, String("Client_1"))

t = Array{String}(2)
t[1] = "test/1"
t[2] = "test/2"

q = Array{UInt8}(2)
q[1] = EXACTLY_ONCE
q[2] = EXACTLY_ONCE
MqttSubscribe(client, t, q)
