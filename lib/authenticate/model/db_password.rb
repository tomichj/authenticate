require 'authenticate/crypto/bcrypt'


module Authenticate
  module Model

    # Encrypts and stores a password in the database to validate the authenticity of a user while logging in.
    #
    # Authenticate can plug in any crypto provider, but currently only features BCrypt.
    # A crypto provider must provide:
    # * encrypt(secret) - encrypt the secret, @return [String]
    # * match?(secret, encrypted) - does the secret match the encrypted? @return [Boolean]
    #
    # = Columns
    #
    # * encrypted_password - the user's password, encrypted
    #
    # = Methods
    #
    # The following methods are added to your user model:
    # * password_match?(password) - checks to see if the user's password matches the given password
    # * password=(new_password) - encrypt and set the user password
    #
    # = Validations
    #
    # * :password validation, requiring the password is set unless we're skipping due to a password change
    #
    module DbPassword
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:encrypted_password]
      end

      included do
        include crypto_provider
        attr_reader :password
        attr_accessor :password_changing
        validates :password, presence: true, unless: :skip_password_validation?
      end



      module ClassMethods

        # We only have one crypto provider at the moment, but look up the provider in the config.
        def crypto_provider
          Authenticate.configuration.crypto_provider || Authenticate::Crypto::BCrypt
        end

      end



      def password_match?(password)
        match?(password, self.encrypted_password)
      end

      def password=(new_password)
        @password = new_password

        if new_password.present?
          self.encrypted_password = encrypt(new_password)
        end
      end

      private

        # If we already have an encrypted password and it's not changing, skip the validation.
      def skip_password_validation?
        encrypted_password.present? && !password_changing
      end

    end
  end
end

