require 'curb'

c = Curl::Easy.new('http://onliner.muzenza.by/info') do |req|
  req.headers['User-Agent'] = 'curl'
  req.proxy_url = 'http://localhost:3100'
end

c.perform
p c.body
