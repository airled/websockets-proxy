require 'sinatra'
require "amqp"

set :server, 'thin'
set :port, 3100
set :temp, []

get '/' do
  if request.env['HTTP_USER_AGENT'] == 'curl'
    location = request.env['HTTP_LOCATION']
    
    EventMachine.run do
      AMQP.connect(:host => '127.0.0.1') do |connection|
        channel = AMQP::Channel.new(connection)
        puts "Received #{location} from requester"
        puts "Sending #{location} to temp1"
        channel.direct("").publish location, :routing_key => "request"
        channel.queue("response", :auto_delete => true).subscribe do |payload|
          # $answer = payload.to_s
          # puts $answer
          # puts "answer: #{payload}"
          # return payload
          # puts "Received from temp1: #{payload}"
          # connection.close { EventMachine.stop }
          settings.temp << payload
        end
      end
    end

  end

  settings.temp

end

