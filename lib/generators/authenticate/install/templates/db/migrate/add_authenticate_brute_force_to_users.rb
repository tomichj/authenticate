class AddAuthenticateBruteForceToUsers < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :failed_logins_count, :integer, default: 0
    add_column :<%= table_name %>, :lock_expires_at, :datetime, default: nil
  end
end
