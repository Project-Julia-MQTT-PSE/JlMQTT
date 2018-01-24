# Messages

This section documents the MQTT message types and methods related to message formating and framing.

## Types

```@docs
JlMQTT.MqttMsgBase
JlMQTT.MqttMsgConnect
JlMQTT.MqttMsgConnack
JlMQTT.MqttMsgContext
JlMQTT.MqttMsgDisconnect
JlMQTT.MqttMsgPingreq
JlMQTT.MqttMsgPingresp
JlMQTT.MqttMsgPuback
JlMQTT.MqttMsgPubcomp
JlMQTT.MqttMsgPublish
JlMQTT.MqttMsgPubrec
JlMQTT.MqttMsgPubrel
JlMQTT.MqttMsgSuback
JlMQTT.MqttMsgSubscribe
JlMQTT.MqttMsgUnsuback
JlMQTT.MqttMsgUnsubscribe
```

## Definitions

```@docs
JlMQTT.MsgType
JlMQTT.QosLevel
JlMQTT.ConnackCode
```

## Constructors

```@docs
JlMQTT.MqttMsgBase(msgType::JlMQTT.MsgType, msgId::UInt16)
JlMQTT.MqttMsgConnectConstructor(clientId::String)
JlMQTT.MqttMsgConnackConstructor(returnCode::JlMQTT.ConnackCode, sessionPresent::Bool)
```
