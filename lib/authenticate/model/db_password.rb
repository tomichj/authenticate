require 'authenticate/crypto/bcrypt'

module Authenticate
  module Model
    #
    # Encrypts and stores a password in the database to validate the authenticity of a user while logging in.
    #
    # Authenticate can plug in any crypto provider, but currently only features BCrypt.
    #
    # A crypto provider must provide:
    # * encrypt(secret) - encrypt the secret, @return [String]
    # * match?(secret, encrypted) - does the secret match the encrypted? @return [Boolean]
    #
    # = Columns
    # * encrypted_password - the user's password, encrypted
    #
    # = Methods
    # The following methods are added to your user model:
    # * password=(new_password) - encrypt and set the user password
    # * password_match?(password) - checks to see if the user's password matches the given password
    #
    # = Validations
    # * :password validation, requiring the password is set unless we're skipping due to a password change
    #
    module DbPassword
      extend ActiveSupport::Concern

      def self.required_fields(_klass)
        [:encrypted_password]
      end

      included do
        private_class_method :crypto_provider
        include crypto_provider
        attr_reader :password
        validates :password,
                  presence: true,
                  length: { in: password_length },
                  unless: :skip_password_validation?
      end

      def password_match?(password)
        match?(password, encrypted_password)
      end

      def password=(new_password)
        @password = new_password
        self.encrypted_password = encrypt(new_password) unless new_password.nil?
      end

      private

      # Class methods for database password management.
      module ClassMethods
        # We only have one crypto provider at the moment, but look up the provider in the config.
        def crypto_provider
          Authenticate.configuration.crypto_provider || Authenticate::Crypto::BCrypt
        end

        def password_length
          Authenticate.configuration.password_length
        end
      end

      # If we already have an encrypted password and it's not changing, skip the validation.
      def skip_password_validation?
        encrypted_password.present? && !encrypted_password_changed?
      end
    end
  end
end
