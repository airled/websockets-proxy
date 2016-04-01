require_relative '../config/db'

class Profile < Sequel::Model

  many_to_one :account

  def activate
    self.update(active: true)
  end

  def deactivate
    self.update(active: false)
  end

  def active?
    self.active == true
  end

  def exists?(profile)
    !!Profile[name: profile]
  end

end
