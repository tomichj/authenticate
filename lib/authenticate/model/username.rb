module Authenticate
  module Model

    module Username
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:username]
      end

      included do
        before_validation :normalize_username
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
          find_by_username normalize_username(username)
        end

        def normalize_username(username)
          username.to_s.downcase.gsub(/\s+/, '')
        end
      end

      def normalize_username
        self.username = self.class.normalize_username(username)
      end

    end

  end
end
