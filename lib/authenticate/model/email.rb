require 'email_validator'

module Authenticate
  module Model

    # Use :email as the identifier for the user. Must be unique to the system.
    #
    # = Columns
    # - :email containing the email address of the user
    #
    # = Validations
    # - :email requires email is set, validations the format, and ensure it is unique
    #
    # = Callbacks
    # - :normalize_email - normalize the email, removing spaces etc, before saving
    #
    # = Methods
    # - :email - require the email address is set and is a valid format
    #
    # = class methods
    # - authenticate(email, password) - find user with given email, validate their password, return the user.
    # - normalize_email(email) - clean up the given email and return it.
    # - find_by_normalized_email(email) - normalize the given email, then look for the user with that email.
    #
    module Email
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:email]
      end

      included do
        before_validation :normalize_email
        validates :email,
                  email: { strict_mode: true },
                  presence: true,
                  uniqueness: { allow_blank: true }
      end


      module ClassMethods

        def credentials(params)
          # todo closure from configuration
          [params[:session][:email], params[:session][:password]]
        end

        def authenticate(credentials)
          user = find_by_credentials(credentials)
          user && user.password_match?(credentials[1]) ? user : nil
        end

        def find_by_credentials(credentials)
          email = credentials[0]
          puts "find_by_credentials email: #{email}"
          find_by_email normalize_email(email)
        end

        def normalize_email(email)
          email.to_s.downcase.gsub(/\s+/, '')
        end

      end

      # Sets the email on this instance to the value returned by
      # {.normalize_email}
      #
      # @return [String]
      def normalize_email
        self.email = self.class.normalize_email(email)
      end
    end

  end
end

