
"""
TODO: make this work
"""

mutable struct MqttNetworkChannel
    socket::TCPSocket
    remoteAddr::String
    remotePort::Int
end
MqttNetworkChannel() = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883)

function Open(network::MqttNetworkChannel)
    println("open channel")
    network.socket = connect(network.remoteAddr, network.remotePort)
    println(network.socket)
    println("test")
end

function Close(network::MqttNetworkChannel)
    close(network.socket)
end

function Write(network::MqttNetworkChannel, buffer::Vector{UInt8})
    if !isopen(network) throw(ErrorException("Socket error")) end
    # write(network.socket, buffer)
end

function Read(network::MqttNetworkChannel, buffer::Vector{UInt8})
    if !isopen(network) throw(ErrorException("Socket error")) end
    # read(network.socket, buffer)
    return length(buffer)
end
