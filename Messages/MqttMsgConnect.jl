
include("Definitions.jl")
include("MqttMsgBase.jl")

# CONSTANTS
const KEEP_ALIVE_PERIOD_DEFAULT = 60
const MAX_KEEP_ALIVE = 65535
const MAX_CLIENT_ID_LENGTH = 23
const MIN_CLIENT_ID_LENGTH = 1
const MAX_WILL_TOPIC_LENGTH = 65535
const MIN_WILL_TOPIC_LENGTH = 1
const MAX_WILL_MESSAGE_LENGTH = 65535
const MIN_WILL_MESSAGE_LENGTH = 1
const MAX_USERNAME_LENGTH = 65535
const MIN_USERNAME_LENGTH = 1
const MAX_PASSWORD_LENGTH = 65535
const MIN_PASSWORD_LENGTH = 1

const USERNAME_FLAG_MASK = 0x80
const USERNAME_FLAG_OFFSET = 0x07
const PASSWORD_FLAG_MASK = 0x40
const PASSWORD_FLAG_OFFSET = 0x06
const WILL_FLAG_OFFSET = 0x02
const WILL_QOS_FLAG_OFFSET = 0x03
const WILL_RETAIN_FLAG_OFFSET = 0x05
const CLEAN_SESSION_FLAG_OFFSET = 0x01

mutable struct WillOptions
    willRetain::Bool
    willQosLevel::QosLevel
    willTopic::String
    willMessage::String
end

mutable struct MqttMsgConnect <: MqttPacket
    msgBase::MqttMsgBase
    clientId::String
    username::String
    password::String
    will::WillOptions
    willFlag::Bool
    cleanSession::Bool
    keepAlivePeriod::Int
    protocolName::String
    protocolLevel::UInt8
    flags::UInt8

    # default constructor
    #MqttMsgConnect() = new(msgBase, clientId, username, password, will, willFlag, cleanSession, keepAlivePeriod, protocolName, protocolLevel, flags)

    # constructor
    function MqttMsgConnect(clientId::String;
        username = String(""),
        password = String(""),
        will = WillOptions(false, AT_MOST_ONCE, String(""), String("")),
        willFlag = false,
        cleanSession = false,
        keepAlivePeriod = KEEP_ALIVE_PERIOD_DEFAULT,
        protocolName = "MQTT",
        protocolLevel = 4,
        flags = 0)

        this = new()
        this.msgBase = MqttMsgBase(CONNECT_TYPE)
        this.clientId = clientId
        this.username = username
        this.password = password
        this.will = will
        this.willFlag = willFlag
        this.cleanSession = cleanSession
        this.keepAlivePeriod = keepAlivePeriod
        this.protocolName = protocolName
        this.protocolLevel = protocolLevel

        # Set connect flags
        flags |= (length(username) > 0) ? (1 << USERNAME_FLAG_OFFSET) : flags
        flags |= (length(password) > 0) ? (1 << PASSWORD_FLAG_OFFSET) : flags
        flags |= (will.willRetain) ? (1 << WILL_RETAIN_FLAG_OFFSET) : flags
        # only if will flag is set, we have to use will QoS level (otherwise it MUST be 0)
        if (willFlag)
          flags |= (UInt8(will.willQosLevel) << WILL_QOS_FLAG_OFFSET)
        end
        flags |= (willFlag) ? (1 << WILL_FLAG_OFFSET) : flags
        flags |= (cleanSession) ? (1 << CLEAN_SESSION_FLAG_OFFSET) : flags
        this.flags = flags
        
        return this
    end # function
end # struct
# outer constructor - override default
#MqttMsgConnect() = MqttMsgConnect(MqttMsgBase(CONNECT_TYPE), String("clientId123"), String("User1"), String("Password1"), WillOptions(true, AT_MOST_ONCE, "User1WillTopic", "User1WillMessage"), true, true, KEEP_ALIVE_PERIOD_DEFAULT, String("MQTT"), 4, 0)

# Serialize MQTT message connect
# returns a byte array
function Serialize(msgConnect::MqttMsgConnect)

    fixedHeaderSize::Int = 0
    varHeaderSize::Int = 0
    payloadSize::Int = 0
    remainingLength::Int = 0
    index::Int = 1

    msgPacket = 0

    willTopicUtf8 = 0
    willMessageUtf8 = 0
    clientIdUtf8 = 0
    usernameUtf8 = 0
    passwordUtf8 = 0
    protocolNameUtf8 = 0

    if msgConnect.willFlag
        #Check will topic Length
        if length(msgConnect.will.willTopic) < MIN_WILL_TOPIC_LENGTH || length(msgConnect.will.willTopic) > MAX_WILL_TOPIC_LENGTH
            throw(ErrorException("WillTopic length exceeded"))
        #Check that will topic contain no Wildcards
        elseif in('#', msgConnect.will.willTopic) || in('+', msgConnect.will.willTopic)
            throw(ErrorException("WillTopic can't contain a Wildcard"))
        end
        # check will message length
        if length(msgConnect.will.willMessage) < MIN_WILL_MESSAGE_LENGTH || length(msgConnect.will.willMessage) > MAX_WILL_MESSAGE_LENGTH
            throw(ErrorException("WillMessage length exceeded"))
        end
        willTopicUtf8 = convert(Array{UInt8}, msgConnect.will.willTopic)
        willMessageUtf8 = convert(Array{UInt8}, msgConnect.will.willMessage)
        # if will flag is set, will topic and will message MUST be present
        if UInt8(msgConnect.will.willQosLevel) >= 0x03 || willTopicUtf8 == 0 || willMessageUtf8 == 0 || (willTopicUtf8 != 0 && length(willTopicUtf8) == 0) || (willMessageUtf8 != 0 && length(willMessageUtf8) == 0)
            throw(ErrorException("WillMessage error"))
        end
    # if will flag is not set, retain must be 0 and will topic and message MUST NOT be present
    elseif !msgConnect.willFlag && (msgConnect.will.willRetain || willTopicUtf8 != 0 || willMessageUtf8 != 0 || (willTopicUtf8 != 0 && length(willTopicUtf8) != 0) || (willMessageUtf8 != 0 && length(willMessageUtf8 != 0)))
        throw(ErrorException("WillMessage error"))
    end # if msgConnect.willFlag

    # check keepAlive
    if (msgConnect.keepAlivePeriod > MAX_KEEP_ALIVE)
        throw(ErrorException("KeepAlivePeriod error"))
    end
    # check on will QoS Level
    if ((msgConnect.will.willQosLevel < AT_MOST_ONCE) || (msgConnect.will.willQosLevel > EXACTLY_ONCE))
        throw(ErrorException("WillQosLevel error"))
    end
    #Check client id length
    if length(msgConnect.clientId) < MIN_CLIENT_ID_LENGTH || length(msgConnect.clientId) > MAX_CLIENT_ID_LENGTH
        throw(ErrorException("clientId length exceeded"))
    # cleanSession must be set if clientId is empty
    elseif length(msgConnect.clientId) == 0 && cleanSession == false
        throw(ErrorException("clientId error: cleanSession must be true if clientId is empty"))
    end
    clientIdUtf8 = convert(Array{UInt8}, msgConnect.clientId)
    # check if username flag is set
    if (msgConnect.flags & USERNAME_FLAG_MASK) == USERNAME_FLAG_MASK
        #Check username length
        if length(msgConnect.username) > MAX_USERNAME_LENGTH throw(ErrorException("username length exceeded")) end
        usernameUtf8 = convert(Array{UInt8}, msgConnect.username)
    end
    # check if password flag is set
    if (msgConnect.flags & PASSWORD_FLAG_MASK) == PASSWORD_FLAG_MASK
        #Check password length
        if length(msgConnect.password) > MAX_PASSWORD_LENGTH throw(ErrorException("password length exceeded")) end
        passwordUtf8 = convert(Array{UInt8}, msgConnect.password)
    end

    protocolNameUtf8 = convert(Array{UInt8}, msgConnect.protocolName)

    # protocolName size + length field size
    varHeaderSize += length(msgConnect.protocolName) + 2
    # protocol level field size
    varHeaderSize += 1
    # connect flags field size
    varHeaderSize += 1
    # keep alive timer field size
    varHeaderSize += 2

    # client identifier field size
    payloadSize += length(clientIdUtf8) + 2
    # will topic field size
    payloadSize += (willTopicUtf8 != 0) ? (length(willTopicUtf8) + 2) : 0
    # will message field size
    payloadSize += (willMessageUtf8 != 0) ? (length(willMessageUtf8) + 2) : 0
    # username field size
    payloadSize += (usernameUtf8 != 0) ? (length(usernameUtf8) + 2) : 0
    # password field size
    payloadSize += (passwordUtf8 != 0) ? (length(passwordUtf8) + 2) : 0

    remainingLength += (varHeaderSize + payloadSize)

    #building protocol package
    fixedHeaderSize = 1
    tmp::Int = remainingLength
    #Add Length to Fixed header depending on the remainging length
    while true
      fixedHeaderSize += 1
      tmp = round(tmp / 128)
      if !(tmp > 0)
        break
      end
    end
    msgPacket = Array{UInt8, 1}(fixedHeaderSize + varHeaderSize + payloadSize)
    msgPacket[index] = msgConnect.msgBase.fixedHeader
    index += 1

    #Encode remaining length part for fixed header
    index = encodeRemainingLength(remainingLength, msgPacket, index)

    #Move protocol name to packageBuffer
    index = addPacketField(msgPacket, protocolNameUtf8, index)
    # Copy protocol version MQTT 3.1.1 == 4 to package
    msgPacket[index] = msgConnect.protocolLevel
    index += 1
    # Set connect flags
    msgPacket[index] = msgConnect.flags
    index += 1
    # keep alive period
    # MSB
    msgPacket[index] = (msgConnect.keepAlivePeriod >> 8) & 0x00FF
    index += 1
    # LSB
    msgPacket[index] = msgConnect.keepAlivePeriod & 0x00FF
    index += 1
    # client identifier
    index = addPacketField(msgPacket, clientIdUtf8, index)
    # will topic
    if msgConnect.willFlag && (willTopicUtf8 != 0)
      index = addPacketField(msgPacket, willTopicUtf8, index)
    end
    # will message
    if msgConnect.willFlag && (willMessageUtf8 != 0)
      index = addPacketField(msgPacket, willMessageUtf8, index)
    end
    # username
    if usernameUtf8 != 0
      index = addPacketField(msgPacket, usernameUtf8, index)
    end
    # password
    if passwordUtf8 != 0
        index = addPacketField(msgPacket, passwordUtf8, index)
    end

    return msgPacket
end

"""
m = MqttMsgConnect(String("clientId123"))
println(m)
b = Serialize(m)
println(b)
"""
