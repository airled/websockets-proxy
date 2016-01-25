require "bunny"

conn = Bunny.new
conn.start

ch = conn.create_channel
x  = ch.default_exchange

x.publish("Hello!", :routing_key => q.name)

conn.close
