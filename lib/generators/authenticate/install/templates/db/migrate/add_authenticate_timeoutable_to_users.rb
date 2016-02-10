class AddAuthenticateTimeoutableToUsers < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :last_access_at, :datetime, default: nil
  end
end
