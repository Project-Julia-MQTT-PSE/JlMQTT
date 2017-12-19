include("Definitions.jl")

abstract type MqttPacket end

mutable struct MqttMsgBase
    fixedHeader::UInt8
    retain::Bool
    dup::Bool
    qos::QosLevel
    msgId::UInt16


    #MqttMsgBase(msgType, msgId)
    #Constructor generates a message base which can vary depending on parameters passed in.
    #MqttMsgBase() = new(0, false, false, AT_MOST_ONCE, 0)

    # constructor
    function MqttMsgBase(msgType::MsgType, msgId::UInt16;
            retain = false,
            dup = false,
            qos = AT_MOST_ONCE)

        this = new()
        this.retain = retain
        this.dup = dup
        this.qos = qos
        this.msgId = msgId

        # Set fixedHeader field depending on msgType
        if (msgType == CONNECT_TYPE)
            this.fixedHeader = UInt8(CONNECT_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= CONNECT_FLAG_BITS
        elseif (msgType == CONNACK_TYPE)
            this.fixedHeader = UInt8(CONNACK_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= CONNACK_FLAG_BITS
        elseif (msgType == PUBLISH_TYPE)
            this.fixedHeader = UInt8(PUBLISH_TYPE) << MSG_TYPE_OFFSET
            if dup
                this.fixedHeader |= (1 << DUP_FLAG_OFFSET )
            end
            this.fixedHeader |= (UInt8(qos) << QOS_LEVEL_OFFSET)
            if retain
                this.fixedHeader |= 1
            end
            this.fixedHeader
        elseif (msgType == PUBACK_TYPE)
            this.fixedHeader = UInt8(PUBACK_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PUBACK_FLAG_BITS
        elseif (msgType == PUBREC_TYPE)
            this.fixedHeader = UInt8(PUBREC_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PUBREC_FLAG_BITS
        elseif (msgType == PUBREL_TYPE)
            this.fixedHeader = UInt8(PUBREL_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PUBREL_FLAG_BITS
        elseif (msgType == PUBCOMP_TYPE)
            this.fixedHeader = UInt8(PUBCOMP_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PUBCOMP_FLAG_BITS
        elseif (msgType == SUBSCRIBE_TYPE)
            this.fixedHeader = UInt8(SUBSCRIBE_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= SUBSCRIBE_FLAG_BITS
        elseif (msgType == SUBACK_TYPE)
            this.fixedHeader = UInt8(SUBACK_TYPE )<< MSG_TYPE_OFFSET
            this.fixedHeader |= SUBACK_FLAG_BITS
        elseif (msgType == UNSUBSCRIBE_TYPE)
            this.fixedHeader = UInt8(UNSUBSCRIBE_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= UNSUBSCRIBE_FLAG_BITS
        elseif (msgType == UNSUBACK_TYPE)
            this.fixedHeader = UInt8(UNSUBACK_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= UNSUBACK_FLAG_BITS
        elseif (msgType == PINGREQ_TYPE)
            this.fixedHeader = UInt8(PINGREQ_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PINGREQ_FLAG_BITS
        elseif (msgType == PINGRESP_TYPE)
            this.fixedHeader = UInt8(PINGRESP_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= PINGRESP_FLAG_BITS
        elseif (msgType == DISCONNECT_TYPE)
            this.fixedHeader = UInt8(DISCONNECT_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= DISCONNECT_FLAG_BITS
        end
        return this
    end
end #struct

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

nextByte = Vector{UInt8}(1)
size(nextByte)

#decodeRemainingLength(network)
#Decodes the remaining length by taking in a TCP socket as a parameter. The "network"
#parameter is the TCP socket.

function decodeRemainingLength(network)
    multiplier::Int = 1
    value::Int = 0
    digit::Int = 0
    nextByte = Vector{UInt8}(1)

    while(true)
        Read(network, nextByte)
        value += (Int(nextByte[1]) & 127) * multiplier
        if multiplier > 128*128*128 throw(ErrorException("Malformed Remaining Length")) end
        multiplier *= 128
        if (Int(nextByte[1]) & 128) == 0 break end
    end
    return value
end
