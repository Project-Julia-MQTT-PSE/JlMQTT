mutable struct MqttNetworkChannel
    socket::TCPSocket
    remoteAddr::String
    remotePort::Int
end
MqttNetworkChannel() = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883)

function Connect(network::MqttNetworkChannel)
    network.socket = connect(network.remoteAddr, network.remotePort)
end

function Close(network::MqttNetworkChannel)
    close(network.socket)
end

function Write(network::MqttNetworkChannel, buffer::Vector{UInt8})
    #if !isopen(network) throw(ErrorException("Socket error")) end
println("Writting")
     write(network.socket, buffer)
end

function Read(network::MqttNetworkChannel, buffer::Array{UInt8, 1})
    #if !isopen(network) throw(ErrorException("Socket error")) end
    println("Reading")
    readbytes!(network.socket, buffer, length(buffer))
    return length(buffer)
end
