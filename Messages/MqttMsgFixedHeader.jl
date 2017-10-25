module JlMqtt
# CONSTANTS
#############

# mask, offset and size for fixed header fields
const MSG_TYPE_MASK = 0xF0
const MSG_TYPE_OFFSET = 0x04
const MSG_TYPE_SIZE = 0x04
const MSG_FLAG_BITS_MASK = 0x0F
const MSG_FLAG_BITS_OFFSET = 0x00
const MSG_FLAG_BITS_SIZE = 0x04
const DUP_FLAG_MASK = 0x08
const DUP_FLAG_OFFSET = 0x03
const DUP_FLAG_SIZE = 0x01
const QOS_LEVEL_MASK = 0x06
const QOS_LEVEL_OFFSET = 0x01
const QOS_LEVEL_SIZE = 0x02
const RETAIN_FLAG_MASK = 0x01
const RETAIN_FLAG_OFFSET = 0x00
const RETAIN_FLAG_SIZE = 0x01

# MQTT message types
const MQTT_MSG_CONNECT_TYPE = 0x01
const MQTT_MSG_CONNACK_TYPE = 0x02
const MQTT_MSG_PUBLISH_TYPE = 0x03
const MQTT_MSG_PUBACK_TYPE = 0x04
const MQTT_MSG_PUBREC_TYPE = 0x05
const MQTT_MSG_PUBREL_TYPE = 0x06
const MQTT_MSG_PUBCOMP_TYPE = 0x07
const MQTT_MSG_SUBSCRIBE_TYPE = 0x08
const MQTT_MSG_SUBACK_TYPE = 0x09
const MQTT_MSG_UNSUBSCRIBE_TYPE = 0x0A
const MQTT_MSG_UNSUBACK_TYPE = 0x0B
const MQTT_MSG_PINGREQ_TYPE = 0x0C
const MQTT_MSG_PINGRESP_TYPE = 0x0D
const MQTT_MSG_DISCONNCT_TYPE = 0x0E

# Flag Nibble
const MQTT_MSG_CONNECT_FLAG_BITS = 0x00
const MQTT_MSG_CONNACK_FLAG_BITS = 0x00
const MQTT_MSG_PUBLISH_FLAG_BITS = 0x00 # just defined as 0x00 but depends on publish props (dup, qos, _retain)
const MQTT_MSG_PUBACK_FLAG_BITS = 0x00
const MQTT_MSG_PUBREC_FLAG_BITS = 0x00
const MQTT_MSG_PUBREL_FLAG_BITS = 0x02
const MQTT_MSG_PUBCOMP_FLAG_BITS = 0x00
const MQTT_MSG_SUBSCRIBE_FLAG_BITS = 0x02
const MQTT_MSG_SUBACK_FLAG_BITS = 0x00
const MQTT_MSG_UNSUBSCRIBE_FLAG_BITS = 0x02
const MQTT_MSG_UNSUBACK_FLAG_BITS = 0x00
const MQTT_MSG_PINGREQ_FLAG_BITS = 0x00
const MQTT_MSG_PINGRESP_FLAG_BITS = 0x00
const MQTT_MSG_DISCONNECT_FLAG_BITS = 0x00

# QOS levels
const QOS_LEVEL_AT_MOST_ONCE = 0x00
const QOS_LEVEL_AT_LEAST_ONCE = 0x01
const QOS_LEVEL_EXACTLY_ONCE = 0x02

struct MqttMsgFixedHeader
    _byteMap::UInt8

    # Constructor
    function MqttMsgFixedHeader(msgType::UInt8; dupFlag::Bool = true, qosLevel::UInt8 = QOS_LEVEL_AT_MOST_ONCE, _retain::Bool = true)
        if (msgType == MQTT_MSG_CONNECT_TYPE)
             _byteMap = MQTT_MSG_CONNECT_TYPE << MSG_TYPE_OFFSET
             _byteMap = _byteMap | MQTT_MSG_CONNECT_FLAG_BITS
        elseif (msgType == MQTT_MSG_CONNACK_TYPE)
            _byteMap = MQTT_MSG_CONNACK_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_CONNACK_FLAG_BITS
        elseif (msgType == MQTT_MSG_PUBLISH_TYPE)
            _byteMap = MQTT_MSG_PUBLISH_TYPE << MSG_TYPE_OFFSET
            if dupFlag
                _byteMap = _byteMap | (0x01 << DUP_FLAG_OFFSET )
            end
            _byteMap = _byteMap | (qosLevel << QOS_LEVEL_OFFSET)
            if _retain
                _byteMap = _byteMap | 0x01
            end
            _byteMap # if/else return a result
        elseif (msgType == MQTT_MSG_PUBACK_TYPE)
            _byteMap = MQTT_MSG_PUBACK_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PUBACK_FLAG_BITS
        elseif (msgType == MQTT_MSG_PUBREC_TYPE)
            _byteMap = MQTT_MSG_PUBREC_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PUBREC_FLAG_BITS
        elseif (msgType == MQTT_MSG_PUBREL_TYPE)
            _byteMap = MQTT_MSG_PUBREL_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PUBREL_FLAG_BITS
        elseif (msgType == MQTT_MSG_PUBCOMP_TYPE)
            _byteMap = MQTT_MSG_PUBCOMP_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PUBCOMP_FLAG_BITS
        elseif (msgType == MQTT_MSG_SUBSCRIBE_TYPE)
            _byteMap = MQTT_MSG_SUBSCRIBE_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_SUBSCRIBE_FLAG_BITS
        elseif (msgType == MQTT_MSG_SUBACK_TYPE)
            _byteMap = MQTT_MSG_SUBACK_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_SUBACK_FLAG_BITS
        elseif (msgType == MQTT_MSG_UNSUBSCRIBE_TYPE)
            _byteMap = MQTT_MSG_UNSUBSCRIBE_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_UNSUBSCRIBE_FLAG_BITS
        elseif (msgType == MQTT_MSG_UNSUBACK_TYPE)
            _byteMap = MQTT_MSG_UNSUBACK_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_UNSUBACK_FLAG_BITS
        elseif (msgType == MQTT_MSG_PINGREQ_TYPE)
            _byteMap = MQTT_MSG_PINGREQ_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PINGREQ_FLAG_BITS
        elseif (msgType == MQTT_MSG_PINGRESP_TYPE)
            _byteMap = MQTT_MSG_PINGRESP_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_PINGRESP_FLAG_BITS
        elseif (msgType == MQTT_MSG_DISCONNCT_TYPE)
            _byteMap = MQTT_MSG_DISCONNCT_TYPE << MSG_TYPE_OFFSET
            _byteMap = _byteMap | MQTT_MSG_DISCONNECT_FLAG_BITS
        end

    end

end

import Base.show
function Base.show(io::IO, m::MqttMsgFixedHeader)
    print(io, "$(m._byteMap)")
end
m = MqttMsgFixedHeader(MQTT_MSG_PUBLISH_TYPE, dupFlag = false, qosLevel = QOS_LEVEL_EXACTLY_ONCE, _retain = true)
end
