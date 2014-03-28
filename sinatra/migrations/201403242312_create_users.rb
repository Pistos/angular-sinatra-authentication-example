require 'bcrypt'

Sequel.migration do
  up do
    self[:users].insert(
      username: 'aristotle',
      password_encrypted: BCrypt::Password.create('aristotlepassword')
    )
    self[:users].insert(
      username: 'plato',
      password_encrypted: BCrypt::Password.create('platospassword')
    )
  end

  down do
    self[:users].where(username: 'plato').delete
    self[:users].where(username: 'aristotle').delete
  end
end
