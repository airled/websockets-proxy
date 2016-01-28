require 'curb'

# Curl::Easy.http_post('http://onliner.muzenza.by/info', Curl::PostField.content('raz', 'dva')) do |req|
#   req.proxy_url = 'http://localhost:3100'
#   req.headers['User-Agent'] = 'testtest'
#   req.headers['Cookie'] = 'foo=1;bar=2'
# end

# c.perform
# p c.body

# c = Curl::Easy.new('http://www.tut.by:6666/test') do |req|
#   req.proxy_url = 'http://localhost:3100'
# end

# c.perform
# p c.body

Curl.get("http://localhost:3100/test?raz=dva")
Curl.post("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
Curl.put("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
Curl.patch("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
Curl.delete("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
Curl.head("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
Curl.options("http://localhost:3100/test", {raz: 'raz', dva: 'dva'})
