
include("MqttClient.jl")

client = MqttClient()
MqttConnect(client, String("Client_1"))
