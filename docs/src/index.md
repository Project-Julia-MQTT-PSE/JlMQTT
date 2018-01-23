# JlMQTT.jl Documentation

```@contents
Pages = ["index.md", "publicinterface.md", "networking.md", "messages.md"]
Depth = 3
```

## Introduction

JlMQTT is a MQTT client written in Julia programming language.

Message Queue Telemetry Transport is a light weight messaging protocol that enables embedded devices with limited resources to perform asynchronous communication on a constrained network.

MQTT protocol is based on publish/subscribe pattern so that a client can subscribe to one or more topics and receive message that other clients publish on these topics.

For all information about MQTT protocol, plsease visit official web site http://mqtt.org/ .

## Getting Started

To start this MQTT program, run JMqttImplementationTest.jl

### Installation

To install JlMQTT.jl run this on Julia "Atom" IDE and use a program such as Wireshark to show, for example, the publish and subscribe packets being sent across the connection. 


