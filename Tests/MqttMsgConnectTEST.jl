include("MqttClient.jl")
using Base.Test
#using MQTT


try
@Test "Connection Test" begin

  client = MqttClient()

  @test MqttConnect(client, String("Client_1")) == 0x00

end
