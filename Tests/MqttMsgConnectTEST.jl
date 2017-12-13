include("../MqttClient.jl")
include("../Messages/Definitions.jl")
include("../Messages/MqttMsgSubscribe.jl")
using Base.Test

#==
Test Failed
  Expression:
MqttConnect(client, String("Client_1")) == 0x00
   Evaluated: CONN_ACCEPTED::ConnackCode = 0 == 0x00 ==#
   @testset "MqttConnect" begin
   client = MqttClient()
   @test MqttConnect(client, String("Client_1")) == CONN_ACCEPTED
   end

# trying to test return QosLevel codes are equal to 0x00, 0x01, 0x02 when subscribing
#function MqttSubscribe(client::MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})
  #subscribe::MqttMsgSubscribe = MqttMsgSubscribe(MqttMsgBase(SUBSCRIBE_TYPE, client.staticMsgId), topics, qosLevels)
  #client.staticMsgId += 1
  #Write(client.channel, Serialize(subscribe))
#end
#Error here is "testset" not defined, need to resolve
@testset "MqttSubscribe" begin

    t = Array{String}(2)
    t[1] = "test/1"
    t[2] = "test/2"

    q = Array{UInt8 }(2)
    q[1] = AT_MOST_ONCE
    q[2] = AT_LEAST_ONCE

    client = MqttClient()
    #MqttSubscribe(client, t, q)
    MqttConnect(client, String("Client_1"))
    #msgReceivedChannel holds the values of the subback return codes
    MqttSubscribe(client, t, q)
    result = take!(client.msgReceivedChannel)
    result.grantedQosLevels[2] = AT_LEAST_ONCE

end
