include("../MqttClient.jl")
using Base.Test
#using MQTT


client = MqttClient()
@test MqttConnect(client, String("Client_1")) == 0x00
