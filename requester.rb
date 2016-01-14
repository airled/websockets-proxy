require 'curb'

request = Curl::Easy.new('http://localhost:6666') do |req|
  req.headers['Location'] = 'http://muzenza.by' 
  req.headers['User-Agent'] = 'curl' 
end

request.perform
