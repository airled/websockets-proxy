require 'curb'

# c = Curl::Easy.new('http://onliner.muzenza.by/info') do |req|
#   req.headers['User-Agent'] = 'curl'
#   req.proxy_url = 'http://localhost:3100'
# end

# c.perform
# p c.body

# Curl.get("http://localhost:3100")
# Curl.post("http://localhost:3100", {raz: 'raz', dva: 'dva'})
Curl.put("http://localhost:3100", {raz: 'raz', dva: 'dva'})
# Curl.patch("http://localhost:3100", {raz: 'raz', dva: 'dva'})
# Curl.delete("http://localhost:3100", {raz: 'raz', dva: 'dva'})
# Curl.head("http://localhost:3100", {raz: 'raz', dva: 'dva'})
# Curl.options("http://localhost:3100", {raz: 'raz', dva: 'dva'})
