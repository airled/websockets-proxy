require 'redis'

class Queuelist

  DEFAULT_DATABASE = '15'

  def initialize(db_number=DEFAULT_DATABASE)
    @list = Redis.new(db: db_number)
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
