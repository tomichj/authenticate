class AddAuthenticateTrackableToUsers < ActiveRecord::Migration

  def change
    add_column :users, :current_sign_in_at, :datetime, default: nil
    add_column :users, :current_sign_in_ip, :string, limit: 128
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :last_sign_in_ip, :string, limit: 128
    add_column :users, :sign_in_count, :integer, default: 0
  end

end
