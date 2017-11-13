# MQTT Client

include("MqttMessages/Definitions.jl")
include("MqttMessages/MqttMsgConnect.jl")

mutable struct MqttClient

end

function Connect(clientId::String, username::String, password::String;
    will::WillOptions = WillOptions(false, AT_MOST_ONCE, String("aWillTopic"), String("aWillMessage")),
    willFlag::Bool = true,
    cleanSession::Bool = true,
    keepAlivePeriod::Int = KEEP_ALIVE_PERIOD_DEFAULT)

    msgConnect = MqttMsgConnect(String("User1ClientId"))
    print(msgConnect)

"""
    # TODO: connect to broker
    try
        broker = connect("ipadress", 2001)
        broker = connect(2001)
        @async while true
           write(STDOUT,readline(broker))
        end
        getalladdrinfo("localhost")
        println(broker,"Hello World from the Echo Server")
        close(broker)

    catch err
        showerror(STDOUT, err, backtrace()); println()
    end
"""
end #function

function Disconnect()

end

function Subscribe()

end

function Unsubscribe()

end

function Publish()

end


Connect("client-id-1", "user1", "password1")
