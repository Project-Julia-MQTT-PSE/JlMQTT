# MQTT 3.1.1 connect message

module JlMqtt

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

#=Represents a CONNECT Package which can be send to the Broker

=#
struct MqttMsgConnect
  msgPackage::Array{UInt8,1}

  # Constructor
  function MqttMsgConnect(fixedHeader::UInt8, clientId::String, username::String, password::String;
      willRetain::Bool = false,
      willFlag::Bool = true,
      # QOS_LEVEL_AT_MOST_ONCE = 0x00
      willQosLevel::UInt8 = 0x00,
      willTopic::String = "aWillTopic",
      willMessage::String = "aWillMessage",
      clientSession::Bool = true,
      keepAlivePeriod::Int = KEEP_ALIVE_PERIOD_DEFAULT,
      protocolName::String = "MQTT",
      protocolLevel::UInt8 = 0x04)

    fixedHeaderSize::Int = 0
    varHeaderSize::Int = 0
    payloadSize::Int = 0
    remainingLength::Int = 0
    index::Int = 1
    connectFlags::UInt8 = 0x00

    #Check will topic Length
    (endof(willTopic) < MIN_WILL_TOPIC_LENGTH || endof(willTopic) > MAX_WILL_TOPIC_LENGTH) ? throw(ErrorException("WillTopic length exceeded")) : 0x00
    #Check that will topic contain no Wildcards
    (in('#', willTopic) || in('+', willTopic)) ? throw(ErrorException("WillTopic can't contain a Wildcard")) : 0x00
    willTopicUtf8 = (willFlag && endof(willTopic) > 0) ? convert(Array{UInt8}, willTopic) : 0x00
    # check will message length
    (endof(willMessage) < MIN_WILL_MESSAGE_LENGTH || endof(willMessage) > MAX_WILL_MESSAGE_LENGTH) ? throw(ErrorException("WillMessage length exceeded")) : 0x00
    willMessageUtf8 = (willFlag && endof(willMessage) > 0) ? convert(Array{UInt8}, willMessage) : 0x00

    # if will flag is set, will topic and will message MUST be present
    if (willFlag && ((willQosLevel >= 0x03) || (willTopicUtf8 == 0x00) || (willMessageUtf8 == 0x00) ||
      ((willTopicUtf8 != 0x00) && (endof(willTopicUtf8) == 0)) ||
      ((willMessageUtf8 != 0x00) && (endof(willMessageUtf8) == 0))))
      throw(ErrorException("WillMessage error"))
    # if will flag is not set, retain must be 0 and will topic and message MUST NOT be present
    elseif (!willFlag && ((willRetain) || (willTopicUtf8 != 0x00) || (willMessageUtf8 != 0x00) ||
      ((willTopicUtf8 != 0x00) && (endof(willTopicUtf8) != 0)) ||
      ((willMessageUtf8 != 0x00) && (endof(willMessageUtf8) != 0))))
      throw(ErrorException("WillMessage error"))
    end
    # check keepAlive
    if (keepAlivePeriod > MAX_KEEP_ALIVE)
      throw(ErrorException("KeepAlivePeriod error"))
    end
    # check on will QoS Level
    # QOS_LEVEL_AT_MOST_ONCE = 0x00
    # QOS_LEVEL_EXACTLY_ONCE = 0x02
    if ((willQosLevel < 0x00) || (willQosLevel > 0x02))
      throw(ErrorException("WillQosLevel error"))
    end

    #Check client id length and convert to utf8
    (endof(clientId) < MIN_CLIENT_ID_LENGTH || endof(clientId) > MAX_CLIENT_ID_LENGTH) ? throw(ErrorException("clientId length exceeded")) : 0x00
    clientIdUtf8 = (endof(clientId) > 0 && endof(clientId) < MAX_CLIENT_ID_LENGTH ) ? convert(Array{UInt8}, clientId) : 0x00
    #Check username length and convert to utf8
    (endof(username) < MIN_USERNAME_LENGTH || endof(username) > MAX_USERNAME_LENGTH) ? throw(ErrorException("username length exceeded")) : 0x00
    usernameUtf8 = (endof(username) > 0 && endof(username) < MAX_USERNAME_LENGTH ) ? convert(Array{UInt8}, username) : 0x00
    #Check client id length and convert to utf8
    (endof(password) < MIN_PASSWORD_LENGTH || endof(password) > MAX_PASSWORD_LENGTH) ? throw(ErrorException("password length exceeded")) : 0x00
    passwordUtf8 = (endof(password) > 0 && endof(password) < MAX_PASSWORD_LENGTH) ? convert(Array{UInt8}, password) : 0x00

    protocolNameUtf8 = (endof(protocolName) > 0) ? convert(Array{UInt8}, protocolName) : 0x00

    # protocolName size + length field size
    varHeaderSize += endof(protocolName) + 2
    # protocol level field size
    varHeaderSize += 1
    # connect flags field size
    varHeaderSize += 1
    # keep alive timer field size
    varHeaderSize += 2

    # client identifier field size
    payloadSize += endof(clientIdUtf8) + 2
    # will topic field size
    payloadSize += (willTopicUtf8 != 0x00) ? (endof(willTopicUtf8) + 2) : 0
    # will message field size
    payloadSize += (willMessageUtf8 != 0x00) ? (endof(willMessageUtf8) + 2) : 0
    # username field size
    payloadSize += (usernameUtf8 != 0x00) ? (endof(usernameUtf8) + 2) : 0
    # password field size
    payloadSize += (passwordUtf8 != 0x00) ? (endof(passwordUtf8) + 2) : 0

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
    msgPackage = Array{UInt8, 1}(fixedHeaderSize + varHeaderSize + payloadSize)
    msgPackage[index] = fixedHeader
    index += 1

    #Encode remaining length part for fixed header
    digit::Int = 0
    while true
      digit = mod(remainingLength,UInt8)
      remainingLength = round(remainingLength / 128)
      if remainingLength > 0
        digit = digit | 0x80
      end
      msgPackage[index] = convert(UInt8, digit)
      index += 1
      remainingLength > 0 ? 0x00 : break
    end

    #Move protocol name to packageBuffer
    #First MSB byte
    msgPackage[index] = (endof(protocolNameUtf8) >> 8) & 0x00FF
    index += 1
    #Second LSB byte
    msgPackage[index] = endof(protocolNameUtf8) & 0x00FF
    index += 1
    #Copy protocolName to package
    for c in protocolNameUtf8
      msgPackage[index] = c
      index += 1
    end
    # Copy protocol version MQTT 3.1.1 == 0x04 to package
    msgPackage[index] = 0x04
    index += 1

    # Set connect flags
    # USERNAME_FLAG_OFFSET = 0x07
    connectFlags |= (usernameUtf8 != 0x00) ? (1 << 0x07) : 0x00
    # PASSWORD_FLAG_OFFSET = 0x06
    connectFlags |= (passwordUtf8 != 0x00) ? (1 << 0x06) : 0x00
    # WILL_RETAIN_FLAG_OFFSET = 0x05
    connectFlags |= (willRetain) ? (1 << 0x05) : 0x00
    # only if will flag is set, we have to use will QoS level (otherwise it MUST be 0)
    if (willFlag) # WILL_QOS_FLAG_OFFSET = 0x03
      connectFlags |= (willQosLevel << 0x03)
    end
    # WILL_FLAG_OFFSET = 0x02
    connectFlags |= (willFlag) ? (1 << 0x02) : 0x00
    # CLEAN_SESSION_FLAG_OFFSET = 0x01
    connectFlags |= (clientSession) ? (1 << 0x01) : 0x00
    msgPackage[index] = connectFlags
    index += 1

    # keep alive period
    # MSB
    msgPackage[index] = ((keepAlivePeriod >> 8) & 0x00FF)
    index += 1
    # LSB
    msgPackage[index] = (keepAlivePeriod & 0x00FF)
    index += 1

    # client identifier
    # TODO: check if (clientId == 0 && cleanSession == 1)
    # MSB
    msgPackage[index] = ((length(clientIdUtf8) >> 8) & 0x00FF)
    index += 1
    # LSB
    msgPackage[index] = (length(clientIdUtf8) & 0x00FF)
    index += 1
    #Copy client id to Package
    for c in clientIdUtf8
      msgPackage[index] = c
      index += 1
    end

    # will topic
    if (willFlag && (willTopicUtf8 != 0x00))
      # MSB
      msgPackage[index] = ((endof(willTopicUtf8) >> 8) & 0x00FF)
      index += 1
      # LSB
      msgPackage[index] = (endof(willTopicUtf8) & 0x00FF)
      index += 1
      #Copy will topic to Package
      for c in willTopicUtf8
        msgPackage[index] = c
        index += 1
      end
    end

    # will message
    if (willFlag && (willMessageUtf8 != 0x00))
      # MSB
      msgPackage[index] = ((endof(willMessageUtf8) >> 8) & 0x00FF)
      index += 1
      # LSB
      msgPackage[index] = (endof(willMessageUtf8) & 0x00FF)
      index += 1
      for c in willMessageUtf8
        msgPackage[index] = c
        index += 1
      end
    end

    # username
    if (usernameUtf8 != 0x00)
      # MSB
      msgPackage[index] = ((endof(usernameUtf8) >> 8) & 0x00FF)
      index += 1
      # LSB
      msgPackage[index] = (endof(usernameUtf8) & 0x00FF)
      index += 1
      p = 1
      for c in usernameUtf8
        msgPackage[index] = c
        index += 1
      end
    end

    # password
    if (passwordUtf8 != 0x00)
      # MSB
      msgPackage[index] = ((endof(passwordUtf8) >> 8) & 0x00FF)
      index += 1
      # LSB
      msgPackage[index] = (endof(passwordUtf8) & 0x00FF)
      index += 1
      p = 1
      for c in passwordUtf8
        msgPackage[index] = c
        index += 1
      end
    end
    msgPackage

  end #constructor

end #struct

#m = MqttMsgConnect(0x10, "clientid", "user", "password")
#println(m)

end #module
