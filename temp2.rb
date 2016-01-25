require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    channel  = AMQP::Channel.new(connection)
    channel.queue("request", :auto_delete => true).subscribe do |payload|
      channel.direct("").publish "OHHAI", :routing_key => "response"
    end
  end
end
