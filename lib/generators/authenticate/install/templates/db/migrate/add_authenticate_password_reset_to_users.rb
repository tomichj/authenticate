class AddAuthenticatePasswordResetToUsers < ActiveRecord::Migration
  def change
    add_column :<%= table_name %>, :password_reset_token, :string, default: nil
    add_column :<%= table_name %>, :password_reset_sent_at, :datetime, default: nil
    add_index :<%= table_name %>, :password_reset_token
  end
end

