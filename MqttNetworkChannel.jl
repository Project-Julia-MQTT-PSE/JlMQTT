
"""
TODO: make this work
"""

mutable struct MqttNetworkChannel
    socket::TCPSocket
    remoteAddr::String
    remotePort::Int
end
MqttNetworkChannel() = MqttNetworkChannel(TCPSocket(), String("test.mosquitto.org"),1883)

function Open(network::MqttNetworkChannel)
    network.socket = connect(network.remoteAddr, network.remotePort)
end

function Close(network::MqttNetworkChannel)
    close(network.socket)
end

function Send(network::MqttNetworkChannel, buffer::Array{UInt8, 1})
    if !isopen(network) throw(ErrorException("Socket error")) end
    write(network.socket, "test")
end

function Receive(network::MqttNetworkChannel, buffer::Array{UInt8, 1})
    if !isopen(network) throw(ErrorException("Socket error")) end
    buffer = read(network.socket, buffer.length)
    return length(buffer)
end
