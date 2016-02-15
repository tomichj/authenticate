module Authenticate
  module Model

    # Support 'forgot my password' functionality.
    #
    # = Columns
    # * password_reset_token - token required to reset a password
    # * password_reset_sent_at - datetime password reset token was emailed to user
    # * email - email address of user
    #
    # = Methods
    # * update_password(new_password) - call password setter below, generate a new session token if user.valid?, & save
    # * forgot_password! - generate a new password reset token, timestamp, and save
    # * reset_password_period_valid? - is the password reset token still usable?
    #
    module PasswordReset
      extend ActiveSupport::Concern

      def self.required_fields(_klass)
        [:password_reset_token, :password_reset_sent_at, :email]
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
        return false unless reset_password_period_valid?

        self.password_changing = true
        self.password = new_password

        if valid?
          clear_reset_password_token
          generate_session_token
        end

        save
      end

      # Generates a {#password_reset_token} for the user, which allows them to reset
      # their password via an email link.
      #
      # The user model is saved without validations. Any other changes you made to
      # this user instance will also be persisted, without validation.
      # It is intended to be called on an instance with no changes (`dirty? == false`).
      #
      # @return [Boolean] Was the save successful?
      def forgot_password!
        self.password_reset_token = Authenticate::Token.new
        self.password_reset_sent_at = Time.now.utc
        save validate: false
      end

      # Checks if the reset password token is within the time limit.
      # If the application's reset_password_within is nil, then always return true.
      #
      # Example:
      #   # reset_password_within = 1.day and reset_password_sent_at = today
      #   reset_password_period_valid?   # returns true
      #
      def reset_password_period_valid?
        reset_within = Authenticate.configuration.reset_password_within
        return true if reset_within.nil?
        self.password_reset_sent_at &&  self.password_reset_sent_at.utc >= reset_within.ago.utc
      end

      private

      def clear_reset_password_token
        self.password_reset_token = nil
        self.password_reset_sent_at = nil
      end

    end
  end
end
