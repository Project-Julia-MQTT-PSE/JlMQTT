include("Definitions.jl")
include("MqttMsgBase.jl")

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const QOS_LEVEL_MASK = 0x06

#=Represent a PUBLISH Package which can be send to the Broker

fixedHeader = the FixedHeader value

topic = topic to which the message will be published

message = to be published message

messageId = OPTIONAL, only required if QoS level is set to level 1 or 2, to identify a specific message

=#

mutable struct MqqtMsgPublish <: MqttPacket
  msgBase::MqttMsgBase
  topic::String
  message::String
  messageId::UInt8

  function MqqtMsgPublish(topic::String,
    message::String;
    messageId::UInt8 = 0x00,
    _retain = false,
    _dup = false,
    _qos = UInt8(AT_MOST_ONCE))

    this = new()
    this.msgBase = MqttMsgBase(PUBLISH_TYPE, retain=_retain, dup=_dup, qos=_qos, msgId=messageId)
    this.message = message
    this.topic = topic
    this.messageId = messageId
  end

end

function Serialize(msgPublish::MqqtMsgPublish)
  fixedHeaderSize::Int = 0
  varHeaderSize::Int = 0
  payloadSize::Int = 0
  remainingLength::Int = 0
  index::Int = 1

  msgPackage::Array{UInt8,1}


  #Check that Topic contain no Wildcards
  in('#', topic) || in('+', topic) ? throw(ErrorException("Topic can't contain a Wildcard")) : 0x00
  #Check Topic Length
  (endof(topic) < MIN_TOPIC_LENGTH || endof(topic) > MAX_TOPIC_LENGTH) ? throw(ErrorException("Topic length exceeded")) : 0x00
  #Check if QoS Level is wrong
  if (fixedHeader & QOS_LEVEL_MASK) == QOS_LEVEL_MASK
    throw(ErrorException("QoS is set to a wrong value"))
  end

  topicUtf8 = convert(Array{UInt8}, topic)

  #Topic Length 2 two for MSB & LSB
  varHeaderSize += endof(topicUtf8) + 2

  #If Qos level is 1 or 2 add the Message ID LSB & MSB
  if ((fixedHeader & QOS_LEVEL_MASK) == EXACTLY_ONCE || (fixedHeader & QOS_LEVEL_MASK) == 0x04)
    varHeaderSize += MESSAGE_ID_SIZE
  end

  if message != ""
    payloadSize += endof(message)
  end

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
      index = encodeRemainingLength(remainingLength, msgPackage, index)

      #Move topic name to packageBuffer
      #First MSB byte
      msgPackage[index] = (endof(topicUtf8) >> 8) & 0x00FF
      index += 1
      #Second LSB byte
      msgPackage[index] = endof(topicUtf8) & 0x00FF
      index += 1
      #Copy Topic to Package
      p::Int = 1
      while p <= endof(topicUtf8)
        msgPackage[index] = topicUtf8[p]
        index += 1
        p += 1
      end
      #Set Message Id if QoS level is Set
      if ((fixedHeader & 0x06) == 0x04 || (fixedHeader & 0x06) == 0x02)
        #check if messageId isn't 0
        if messageId == 0
          throw(ErrorException("Message Id can not be 0"))
        end
      #Message Id MSB
      msgPackage[index] = ((messageId >> 8) & 0x00FF)
      index += 1
      #Message Id LSB
      msgPackage[index] = (messageId & 0x00FF)
      index += 1
      end
      #Copy message to Package
      p = 1
      t = convert(Array{UInt8}, message)
      while p <= endof(t)
        msgPackage[index] = t[p]
        index += 1
        p += 1
      end
      return msgPackage
end

#m::MqqtMsgPublish = MqqtMsgPublish("asecd", "test")
#println(m)
#b = Serialize(m)
#println(b)

