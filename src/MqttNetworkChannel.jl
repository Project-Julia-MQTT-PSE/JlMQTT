
"""
    JlMQTT.MqttNetworkChannel

Representation of a connection to a broker which provides a `TCPSocket`, remote address as String and remote port as Integer.
"""
mutable struct MqttNetworkChannel
    socket::TCPSocket
    remoteAddr::String
    remotePort::Int
end
MqttNetworkChannel() = MqttNetworkChannel(TCPSocket(), "test.mosquitto.org", 1883)

"""
    JlMQTT.Connect(network::JlMQTT.MqttNetworkChannel)

Connects to a broker.

## Parameters:
\nnetwork - [in] [`JlMQTT.MqttNetworkChannel`](@ref)
"""
function Connect(network::MqttNetworkChannel)
    network.socket = connect(network.remoteAddr, network.remotePort)
end

"""
    JlMQTT.Close(network::JlMQTT.MqttNetworkChannel)

Closes connection to a broker.

## Parameters:
\nnetwork - [in] [`JlMQTT.MqttNetworkChannel`](@ref)
"""
function Close(network::MqttNetworkChannel)
    close(network.socket)
end

"""
    JlMQTT.Write(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})

Sends `buffer::Vector{UInt8}` to a broker.

## Parameters:
\nnetwork - [in] [`JlMQTT.MqttNetworkChannel`](@ref)
\nbuffer - [in] Vector{UInt8}
"""
function Write(network::MqttNetworkChannel, buffer::Vector{UInt8})
    #if !isopen(network) throw(ErrorException("Socket error")) end
#println("Writting")
     write(network.socket, buffer)
end

"""
    JlMQTT.Read(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})

Receives `buffer::Vector{UInt8}` from a broker.

## Parameters:
\nnetwork - [in] [`JlMQTT.MqttNetworkChannel`](@ref)
\nbuffer - [in] Vector{UInt8}

## Returns:
\n[out] returns the number of read bytes
"""
function Read(network::MqttNetworkChannel, buffer::Array{UInt8, 1})
    #if !isopen(network) throw(ErrorException("Socket error")) end
    #println("Reading")
    readbytes!(network.socket, buffer, length(buffer))
    #println("Reading ended")
    return length(buffer)
end
