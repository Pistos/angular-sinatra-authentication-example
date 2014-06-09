require 'bcrypt'

Sequel.migration do
  up do
    self[:users].insert(
      username: 'aristotle',
      password_encrypted: BCrypt::Password.create('aristotlespassword')
    )
    self[:users].insert(
      username: 'plato',
      password_encrypted: BCrypt::Password.create('platospassword')
    )
    self[:users].insert(
      username: 'admin',
      password_encrypted: BCrypt::Password.create('adminspassword'),
      access: 9
    )
  end

  down do
    self[:users].where(username: 'admin').delete
    self[:users].where(username: 'plato').delete
    self[:users].where(username: 'aristotle').delete
  end
end
