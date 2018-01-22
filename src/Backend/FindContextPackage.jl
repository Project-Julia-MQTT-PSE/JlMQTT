include("../MqttClient.jl")
include("../Messages/Definitions.jl")
include("../Messages/MqttMsgContext.jl")


#Search for context message in the queue
#No return value
function FindContextPackage(client::MqttClient, messageId::UInt16, flow::MqttMsgFlow)
  lock(client.contextQueueLock)
  count::Int = length(client.contextMsgChannel.data)
  while count != 0
    tmp::MqttMsgContext = take!(client.contextMsgChannel)
    if tmp.message.msgBase.msgId == messageId && tmp.flow == flow
      unlock(client.contextQueueLock)
      return tmp
    else
      put!(client.contextMsgChannel, tmp)
    end
    count -= 1
  end
  unlock(client.contextQueueLock)
  return 0
end
