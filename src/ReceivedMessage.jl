#ReceivedMessage Package is what the client program will receive over the channel
mutable struct ReceivedMessage
  topic::String
  message::String
end
