class AddAuthenticateTimeoutableToUsers < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :<%= table_name %>, :last_access_at, :datetime, default: nil
  end
end
