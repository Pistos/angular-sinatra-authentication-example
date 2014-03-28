require 'bcrypt'

module AngularSinatra
  module Model
    class User < Sequel::Model
      def password
        @password ||= BCrypt::Password.new( self[:password_encrypted] )
      end

      def password=(new_password)
        self[:password_encrypted] = BCrypt::Password.create(new_password)
      end
    end
  end
end
