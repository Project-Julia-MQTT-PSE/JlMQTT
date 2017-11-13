include("Definitions.jl")

abstract type MqttPacket end

mutable struct MqttMsgBase
    fixedHeader::UInt8
    retain::Bool
    dup::Bool
    qos::QosLevel
    msgId::Int

    # default constructor
    MqttMsgBase() = new(fixedHeader, retain, dup, qos, msgId)
    # constructor
    function MqttMsgBase(msgType::MsgType;
            retain = false,
            dup = false,
            qos = UInt8(AT_MOST_ONCE),
            msgId = 0)

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
            this.fixedHeader |= (qos << QOS_LEVEL_OFFSET)
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
        elseif (msgType == DISCONNCT_TYPE)
            this.fixedHeader = UInt8(DISCONNCT_TYPE) << MSG_TYPE_OFFSET
            this.fixedHeader |= DISCONNECT_FLAG_BITS
        end
        return this
    end
end #struct


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

#
# TODO: receive bytes from network stream
#
function decodeRemainingLength(network)
    multiplier::Int = 1
    value::Int = 0
    encodedByte::Vector{UInt8}(1)

    while(true)
        numerOfBytes = Receive(network, encodedByte)
        value += (encodedByte & 127) * multiplier
        if multiplier > 128*128*128 throw(ErrorException("Malformed Remaining Length")) end
        multiplier *= 128
        if (encodedByte & 128) == 0 break end
    end

    return value
end
