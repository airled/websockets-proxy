require_relative '../config/db'

class Profile < Sequel::Model

  many_to_one :account

end
