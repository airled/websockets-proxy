require_relative '../config/db'
require 'bcrypt'

class Account < Sequel::Model

  one_to_many :profiles

  def has_password?(password)
    ::BCrypt::Password.new(self.crypted_password) == password
  end

  def has_profile?(profile_name)
    !!(Profile[account_id: self.id, name: profile_name])
  end

  def has_profile_with_queue?(queue)
    !!(Profile[account_id: self.id, queue: queue])
  end
  
end
