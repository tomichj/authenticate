module Authenticate
  module Model

    # Use :username as the identifier for the user. Username must be unique.
    #
    # = Columns
    # * username - the username of your user
    #
    # = Validations
    # * :username requires username is set, ensure it is unique
    #
    # = class methods
    # * credentials(params) - return the credentials required for authorization by username
    # * authenticate(credentials) - find user with given username, validate their password, return the user if authenticated
    # * find_by_credentials(credentials) - find and return the user with the username in the credentials
    #
    module Username
      extend ActiveSupport::Concern

      def self.required_fields(_klass)
        [:username, :email]
      end

      included do
        # before_validation :normalize_username
        validates :username,
                  presence: true,
                  uniqueness: { allow_blank: true }
      end

      module ClassMethods
        def credentials(params)
          [params[:session][:username], params[:session][:password]]
        end

        def authenticate(credentials)
          user = find_by_credentials(credentials)
          user && user.password_match?(credentials[1]) ? user : nil
        end

        def find_by_credentials(credentials)
          username = credentials[0]
          find_by_username username
        end

      end

    end

  end
end
