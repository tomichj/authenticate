class CreateUsers < ActiveRecord::Migration
  def change

    create_table :users do |t|
          t.string :email
          t.string :encrypted_password, limit: 128
          t.string :session_token, limit: 128
          t.datetime :current_sign_in_at
          t.string :current_sign_in_ip, limit: 128
          t.datetime :last_sign_in_at
          t.string :last_sign_in_ip, limit: 128
          t.integer :sign_in_count
        end

    add_index :users, :email
    add_index :users, :session_token
  end
end
