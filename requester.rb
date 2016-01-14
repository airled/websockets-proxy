require 'curb'

http = Curl::Easy.new('http://localhost:4567') do |req|
  req.headers['Location'] = 'http://tut.by' 
  req.headers['User-Agent'] = 'curl'
end

http.perform

p http.body
