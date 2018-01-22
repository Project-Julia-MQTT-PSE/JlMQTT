# Public Interface

This section documents the public interface that provides an abstraction layer on MQTT messages and framing.

```@docs
JlMQTT.MqttConnect(client::JlMQTT.MqttClient, clientId::String)
JlMQTT.MqttDisconnect(client::JlMQTT.MqttClient)
JlMQTT.MqttSubscribe(client::JlMQTT.MqttClient, topics::Vector{String}, qosLevels::Vector{UInt8})
JlMQTT.MqttUnsubscribe(client::JlMQTT.MqttClient, topics::Vector{String})
JlMQTT.MqttPublish(client::JlMQTT.MqttClient, topic::String, message::Vector{UInt8}; qos::JlMQTT.QosLevel = AT_MOST_ONCE, retain::Bool = false)
```

## Types


```@docs
JlMQTT.MqttClient
JlMQTT.MqttClientConstructor
JlMQTT.WillOptions
```
