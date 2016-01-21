require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    channel  = AMQP::Channel.new(connection)
    channel.direct("").publish "BLABLABLA", :routing_key => "response"
  end
end
