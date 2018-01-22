# Networking

This section documents the interface and types needed to connect with a broker.

```@docs
JlMQTT.Connect(network::JlMQTT.MqttNetworkChannel)
JlMQTT.Close(network::JlMQTT.MqttNetworkChannel)
JlMQTT.Write(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})
JlMQTT.Read(network::JlMQTT.MqttNetworkChannel, buffer::Vector{UInt8})
```

## Types

```@docs
JlMQTT.MqttNetworkChannel
```
