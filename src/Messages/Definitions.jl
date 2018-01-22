"""
    JlMQTT.MsgType

Enumeration representing MQTT message types.
"""
# MQTT message types
@enum(MsgType,
CONNECT_TYPE = 0x01,
CONNACK_TYPE = 0x02,
PUBLISH_TYPE = 0x03,
PUBACK_TYPE = 0x04,
PUBREC_TYPE = 0x05,
PUBREL_TYPE = 0x06,
PUBCOMP_TYPE = 0x07,
SUBSCRIBE_TYPE = 0x08,
SUBACK_TYPE = 0x09,
UNSUBSCRIBE_TYPE = 0x0A,
UNSUBACK_TYPE = 0x0B,
PINGREQ_TYPE = 0x0C,
PINGRESP_TYPE = 0x0D,
DISCONNECT_TYPE = 0x0E)

"""
    JlMQTT.QosLevels
Enumeration representing MQTT QoS Levels.
"""
# QOS Levels
@enum(QosLevel,
AT_MOST_ONCE = 0x00,
AT_LEAST_ONCE = 0x01,
EXACTLY_ONCE = 0x02)

"""
    JlMQTT.ConnackCode
Enumeration representing MQTT CONNACK return codes.
"""
# return codes for CONNACK message
@enum(ConnackCode,
CONN_ACCEPTED = 0x00,
CONN_REFUSED_PROT_VERS = 0x01,
CONN_REFUSED_IDENT_REJECTED = 0x02,
CONN_REFUSED_SERVER_UNAVAILABLE = 0x03,
CONN_REFUSED_USERNAME_PASSWORD = 0x04,
CONN_REFUSED_NOT_AUTHORIZED = 0x05)

# Flow og message
@enum(MqttMsgFlow,
ToPublish = 0x01,
ToAcknowledge = 0x02)

#MQTT message state
@enum(MqttMsgState,
WaitForPuback = 0x01,
WaitForPubrec = 0x02,
WaitForPubrel = 0x03,
WaitForPubcomp = 0x04,
WaitForSuback = 0x05,
WaitForUnsuback = 0x06)

# MQTT message flags
const CONNECT_FLAG_BITS = 0x00
const CONNACK_FLAG_BITS = 0x00
const PUBLISH_FLAG_BITS = 0x00
const PUBACK_FLAG_BITS = 0x00
const PUBREC_FLAG_BITS = 0x00
const PUBREL_FLAG_BITS = 0x02
const PUBCOMP_FLAG_BITS = 0x00
const SUBSCRIBE_FLAG_BITS = 0x02
const SUBACK_FLAG_BITS = 0x00
const UNSUBSCRIBE_FLAG_BITS = 0x02
const UNSUBACK_FLAG_BITS = 0x00
const PINGREQ_FLAG_BITS = 0x00
const PINGRESP_FLAG_BITS = 0x00
const DISCONNECT_FLAG_BITS = 0x00

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

#Settings
const MQTT_DEFAULT_CONTEXT_TIMEOUT = 3000
const MQTT_DEFAULT_CONTEXT_RETRY = 3
const MESSAGE_ID_SIZE = 2
