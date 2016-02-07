require 'email_validator'

module Authenticate
  module Model

    # Use :email as the identifier for the user. Email must be unique.
    #
    # = Columns
    # * email - the email address of the user
    #
    # = Validations
    # * :email - require email is set, is a valid format, and is unique
    #
    # = Callbacks
    #
    # = Methods
    # * normalize_email - normalize the email, removing spaces etc, before saving
    #
    # = Class Methods
    # * credentials(params) - return the credentials required for authorization by email
    # * authenticate(credentials) - find user with given email, validate their password, return the user if authenticated
    # * normalize_email(email) - clean up the given email and return it.
    # * find_by_credentials(credentials) - find and return the user with the email address in the credentials
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
          [params[:session][:email], params[:session][:password]]
        end

        def authenticate(credentials)
          user = find_by_credentials(credentials)
          user && user.password_match?(credentials[1]) ? user : nil
        end

        def find_by_credentials(credentials)
          email = credentials[0]
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

