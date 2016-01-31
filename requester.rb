require 'curb'

# c = Curl::Easy.http_post('http://198.20.105.55:6666', Curl::PostField.content('raz', 'dva')) do |req|
#   req.proxy_url = 'http://localhost:3100'
#   req.headers['User-Agent'] = 'testtest'
#   req.headers['Cookie'] = 'foo=1;bar=2'
# end

# p c.body

# c = Curl::Easy.http_post('http://bindingofisaacrebirth.gamepedia.com/') do |req|
c = Curl::Easy.http_post('http://198.20.105.55:6666') do |req|
  req.proxy_url = 'http://localhost:3100'
  req.headers['User-Agent'] = 'testtest'
  req.headers['Cookie'] = 'foo=1;bar=2'
end

puts c.head
puts "/////////////////////////////////////"
puts c.body

# p Curl.get("http://localhost:3100/test?raz=dva")
# Curl.post("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
# Curl.put("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
# Curl.patch("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
# Curl.delete("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
# Curl.head("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
# Curl.options("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
