include("Definitions.jl")

abstract type MqttPacket end

"""
  JlMQTT.MqttMsgBase

Represents the message base with shared values between all MQTT packets.
"""
#Message base represent the shared values between all packages
mutable struct MqttMsgBase
    fixedHeader::UInt8
    msgId::UInt16
end

"""
  JlMQTT.MqttMsgBase(msgType::JlMQTT.MsgType, msgId::UInt16)

Constructs a [`JlMQTT.MqttMsgBase`](@ref).

## Parameters:
\nmsgType - [in] enum [`JlMQTT.MsgType`](@ref)
\nmsgId - [in] message identifier of type UInt16
\nretain - [optional] retain flag of type Boolean
\ndup - [optional] dup flag of type Boolean
\nqos - [optional] [`JlMQTT.QosLevel`](@ref)

## Returns:
\n[out] [`JlMQTT.MqttMsgBase`](@ref)
"""
#Messge Base Constructor
function MqttMsgBase(msgType::MsgType, msgId::UInt16;
        retain = false,
        dup = false,
        qos = AT_MOST_ONCE)
    return MqttMsgBase(mqttheader(retain, qos, dup, msgType), msgId)
end

"""
JlMQTT.encodeRemainingLength(remainingLength::Int, buffer::Array{UInt8, 1}, idx)

Determines remaining length so receiving station can determine how to read sent packet correctly.

## Parameters:
\nremainingLength - [in] type int
\nbuffer - [in] type UInt8 array
\nidx - [in] type int
## Returns:
\n value - type int
"""
#encodeRemainingLength(remainingLength, bufffer, idx)
#Function determines remaining length depending on header size so packets can be
#read correctly by receiving station.
function encodeRemainingLength(remainingLength::Int, buffer::Array{UInt8, 1}, idx)
    digit::Int = 0
    while true
      digit = mod(remainingLength,UInt8)
      remainingLength = round(remainingLength / 128)
      if remainingLength > 0
        digit = digit | 0x80
      end
      buffer[idx] = convert(UInt8, digit)
      idx += 1
      remainingLength > 0 ? 0 : break
    end
    return idx
end

"""
mqttheader(retain::Bool=false, qos::QosLevel=QosLevel(AT_LEAST_ONCE), dup::Bool=false, msgtype::MsgType=PUBLISH_TYPE)

Creates UInt8 format for FixedHeader

## Parameters:
\nretain - [optional] type Boolean
\nqos - [optional] ['QosLevel'](@ref)
\ndup - [optional] type Boolean
\n MsgType - [optional] ['MsgType'](@ref)
## Returns:
\n[out] flags - type UInt8 byte array

"""
#Create the UInt8 format for the FixedHeader
#return fixiedHeader
function mqttheader(retain::Bool=false, qos::QosLevel=QosLevel(AT_LEAST_ONCE), dup::Bool=false, msgtype::MsgType=PUBLISH_TYPE)
    flags::UInt8 = (retain ? 1 : 0)
    flags |= Int(qos) << 1
    flags |= (dup ? 1 : 0) << 3
    flags |= Int(msgtype) << 4
    return flags
end

"""
decodeRemainingLength(network)

Decodes remaining length.

## Parameters:
\nnetwork - [in] type String
## Returns:
\n[out] value tpye Int
"""
#decodeRemainingLength(network)
#Decodes the remaining length by taking in a TCP socket as a parameter.
function decodeRemainingLength(network)
  multiplier::Int = 1
  value::Int = 0
  digit::Int = 0
  nextByte = Vector{UInt8}(1)
  while(true)
    Read(network, nextByte)
    value += (Int(nextByte[1]) & 127) * multiplier
    if multiplier > 128*128*128
      throw(ErrorException("Malformed Remaining Length"))
    end
    multiplier *= 128
    if (Int(nextByte[1]) & 128) == 0
      break
    end
  end
  return value
end
