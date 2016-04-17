require 'redis'

class Queuelist

  def initialize
    @list = Redis::Namespace.new(:queuelist, redis: Redis.new)
  end

  def set(queue)
    @list.set(queue, '')
  end

  def unset(queue)
    @list.del(queue)
  end

  def has_queue?(queue)
    @list.keys.include?(queue)
  end

  def clear
    @list.flushdb
  end

end
