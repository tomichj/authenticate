class AddAuthenticateTimeoutableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_access_at, :datetime, default: nil
  end
end
