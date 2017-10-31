module JlMqtt

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;

#=Represent a PUBLISH Package which can be send to the Broker
fixedHeader = the FixedHeader value
topic = topic to which the message will be published
message = to be published message
messageId = OPTIONAL, only required if QoS level is set to level 1 or 2, to identify a specific message
=#
struct MqttMsgPublish
  msgPackage::Array{UInt8,1}
  function MqttMsgPublish(fixedHeader::UInt8, topic::String, message::String; messageId::UInt8 = 0x00)
    fixedHeaderSize::Int = 0
    varHeaderSize::Int = 0
    payloadSize::Int = 0
    remainingLength::Int = 0
    index::Int = 1

    #Check that Topic contain no Wildcards
    in('#', topic) || in('+', topic) ? throw(ErrorException("Topic can't contain a Wildcard")) : 0x00
    #Check Topic Length
    (endof(topic) < MIN_TOPIC_LENGTH || endof(topic) > MAX_TOPIC_LENGTH) ? throw(ErrorException("Topic length exceeded")) : 0x00
    #Check if QoS Level is wrong
    if (fixedHeader & 0x06) == 0x06
      throw(ErrorException("QoS is set to a wrong value"))
    end

    topicUtf8 = convert(Array{UInt8}, topic)

    #Topic Length 2 two for MSB & LSB
    varHeaderSize += endof(topicUtf8) + 2

    #If Qos level is 1 or 2 add the Message ID LSB & MSB
    if ((fixedHeader & 0x06) == 0x02 || (fixedHeader & 0x06) == 0x04)
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
        msgPackage
  end

end
#Test function call
#m = MqttMsgPublish(0x35, "asecd", "test", messageId = 0x12)
end
