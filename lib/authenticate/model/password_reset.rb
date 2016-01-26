module Authenticate
  module Model

    # * update_password(new_password) - call password setter below, generate a new session token if user.valid?, & save

    module PasswordReset
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:password_reset_token]
      end

      # Sets the user's password to the new value. The new password will be encrypted with
      # the selected encryption scheme (defaults to Bcrypt).
      #
      # Updating the user password also generates a new session token.
      #
      # Validations will be run as part of this update. If the user instance is
      # not valid, the password change will not be persisted, and this method will
      # return `false`.
      #
      # @return [Boolean] Was the save successful?
      def update_password(new_password)
        self.password_changing = true
        self.password = new_password

        if valid?
          self.password_reset_token = nil
          generate_session_token
        end

        save
      end


      def generate_password_reset_token
        self.password_reset_token = Authenticate::Token.new
      end

    end
  end
end
