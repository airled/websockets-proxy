require "amqp"

EventMachine.run do
  AMQP.connect(:host => '127.0.0.1') do |connection|
    channel  = AMQP::Channel.new(connection)
    channel.queue("request", :auto_delete => true).subscribe do |payload|
      puts "Received #{payload} from proxy"
      puts "Sending 'OHHAI' to proxy"
      channel.direct("").publish "OHHAI", :routing_key => "response"
      connection.close { EventMachine.stop }
    end
  end
end
