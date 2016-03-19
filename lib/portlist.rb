require 'redis'

class Portlist

  DEFAULT_DATABASE = '15'

  def initialize(db_number=DEFAULT_DATABASE)
    @portlist = Redis.new(db: db_number)
  end

  def bind(port, queue)
    @portlist.set(port, queue)
  end

  def unbind(port)
    @portlist.del(port)
  end

  def clear
    @portlist.flushdb
  end

  def include?(port)
    !@portlist.get(port).nil?
  end

  def has_queue?(port, queue)
    @portlist.get(port) == queue
  end

end
