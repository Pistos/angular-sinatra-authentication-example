Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :username, null: false
      String :password_encrypted, null: false
      String :token
      Integer :access, null: false, default: 1
    end
  end

  down do
    drop_table :users
  end
end
