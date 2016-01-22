require 'curb'

http = Curl::Easy.new('http://localhost:3100') do |req|
  req.headers['Location'] = 'http://muzenza.by' 
  req.headers['User-Agent'] = 'curl'
  puts "I'm sending: #{req.headers['Location']}"
end

http.perform
puts "I'm received: #{http.body}"
