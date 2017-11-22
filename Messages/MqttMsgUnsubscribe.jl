module JlMqtt

const MAX_TOPIC_LENGTH = 65535;
const MIN_TOPIC_LENGTH = 1;
const MESSAGE_ID_SIZE = 2;
const MQTT_MSG_UNSUBSCRIBE_TYPE = 0x0A;
const MSG_TYPE_OFFSET = 0x04;
const QOS_LEVEL_OFFSET = 0x01;
const DUP_FLAG_OFFSET = 0x03;
const QOS_LEVEL_AT_LEAST_ONCE = 0x01;

struct MqttMsgUnsubscribe
  msgPackage::Array{UInt8,1}
  function MqttMsgUnsubscribe(fixedHeader::UInt8, topic::Array{String,1}, message::String; messageId::UInt8 = 0x00)
    fixedHeaderSize::Int = 0
    varHeaderSize::Int = 0
    payloadSize::Int = 0
    remainingLength::Int = 0
    index::Int = 1

    ((count(topic)) == 0) ? throw(ErrorException("No topics present to unsubscribe from.")) : 0x00

    varHeaderSize = MESSAGE_ID_SIZE
  end
end

    topicsUtf8::Array{byte, 2}

    for t in topicsUtf8

      if endof(topicsUtf8) < MIN_TOPIC_LENGTH || endof(topicsUtf8) > MAX_TOPIC_LENGTH

        payloadSize += 2
        payloadSize += topicsUtf8[t]
      end
    end

      remainingLength += varHeaderSize + payloadSize

      fixedHeaderSize = 1

      temp::int = remainingLength

      do
      fixedHeaderSize += 1
      temp = temp / 128
      while (temp > 0)

      #allocate buffer for message
      byte::buffer = fixedHeaderSize + varHeaderSize + payloadSize

      #TODO: qosLevel = QOS_LEVEL_AT_LEAST_ONCE

      buffer[index] = MQTT_MSG_UNSUBSCRIBE_TYPE << MSG_TYPE_OFFSET | qosLevel << QOS_LEVEL_OFFSET

      buffer[index] |= dupFlag ? 1 << DUP_FLAG_OFFSET : 0x00
      index += 1

      index = encodeRemainingLength(remainingLength, buffer, index)

      # Check if message identifier assigned
      if(messageId == 0) throw(ErrorException("No message identifier assigned."))


      #MSB & LSB
      buffer[index++] = (messageId >> 8) & 0x00FF
      buffer[index++] = (messaageId & 0x00FF)

      topicIdx = 0

      for(topicIdx = 0; topicIdx < topics.length; topicIdx++)

        buffer[index += 1] = (topicsUtf8[topicIdx].length >> 8) & 0x00FF) #MSB
        buffer[index += 1] = (topicsUtf8[topicIdx].length & 0x00FF) #LSB

        # Array.Copy(topicsUtf8[topicIdx], 0, buffer, index, topicsUtf8[topicIdx].Length);

        index += topicsUtf8[topicIdx].Length
      end


      return buffer
