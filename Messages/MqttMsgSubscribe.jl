include("Definitions.jl")
include("MqttMsgBase.jl")

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const QOS_LEVEL_MASK = 0x06

#=Represent a Subscribe Package which can be send to the Broker
fixedHeader = the FixedHeader value
topic = topic to which the message will be published
messageId = OPTIONAL, only required if QoS level is set to level 1 or 2, to identify a specific message
=#

mutable struct MqttMsgSubscribe <: MqttPacket
  msgBase::MqttMsgBase
  topic::String
  message::String
  messageId::UInt8
	
  function MqttMsgSubscribe(
  topic::String, 
  message::String; 
  messageId::UInt8 = 0x00
  _retain = false,
  _dup = false,
  _qos = UInt8(AT_MOST_ONCE))

  this = new()
  this.msgBase = MqttMsgBase(SUBSCRIBE_TYPE, retain=_retain, dup=_dup, qos=_qos, msgId=messageId)
  this.message = message
  this.topic = topic
  this.messageId = messageId

    return this
  end

end
		
function Serialize(msgSubscribe::MqttMsgSubscribe)
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

            #TODO: from subscribe M2MQTT line 192 : recheck this  
 	    topicIdx::Int = 0;
            #byte[][] topicsUtf8 = new byte[this.topics.Length][];
             topicsUtf8::Array{UInt8,2} (count(topic))
            for (topicIdx = 0; topicIdx < (count(topic); topicIdx+=1)
                #check topic length
                if (count(topic[topicInx]) < MIN_TOPIC_LENGTH) || count(topic[topicInx]) > MAX_TOPIC_LENGTH))
                    ? throw(ErrorException("Topic length exceeded")) : 0x0
                    #throw new MqttClientException(MqttClientErrorCode.TopicLength)
				
                #topicsUtf8[topicIdx] = Encoding.UTF8.GetBytes(this.topics[topicIdx])
                topicUtf8 = convert(Array{UInt8}, topic[topicIdx])
                payloadSize += 2; # topic size (MSB, LSB)
                payloadSize += count(topicsUtf8[topicIdx])
                payloadSize[index]; # byte for QoS
                index += 1
                end
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

        topicIdx::Int = 0;
        for (topicIdx = 0; topicIdx < (count(topic); topicIdx+=1)
        
            #topic name
            buffer[index] = (byte)((count(topicsUtf8[topicIdx]) >> 8) & 0x00FF) // MSB
            index += 1
            buffer[index] = (byte)(count(topicsUtf8[topicIdx]) & 0x00FF) // LSB
            index += 1
            Array.Copy(topicsUtf8[topicIdx], 0, buffer, index, count(topicsUtf8[topicIdx]))
            index += count(topicsUtf8[topicIdx])

            #requested QoS
            buffer[index] = qosLevels[topicIdx]
            index += 1
        end
        
        return msgPackage
        
        
