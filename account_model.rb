require_relative './config/db'
require 'bcrypt'

class Account < Sequel::Model

  def confirmed?
    self.confirmed == true
  end

  def has_password?(password)
    ::BCrypt::Password.new(self.crypted_password) == password
  end

  def activate
    self.update(active: true)
  end

  def deactivate
    self.update(active: false)
  end
  
end
