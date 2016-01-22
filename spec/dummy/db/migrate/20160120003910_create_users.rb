class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :encrypted_password
      t.string :session_token
      t.datetime :session_expiration
      t.integer :sign_in_count
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip
      t.datetime :last_access_at
      t.datetime :current_sign_in_at
      t.string :current_sign_in_ip

      t.timestamps null: false
    end
  end
end
