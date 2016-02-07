require 'authenticate/callbacks/lifetimed'

module Authenticate
  module Model

    # Imposes a maximum allowed lifespan on a user's session, after which the session is expired and requires
    # re-authentication.
    #
    # = Configuration
    # Set the maximum session lifetime in the initializer, giving a timestamp.
    #
    #   Authenticate.configure do |config|
    #     config.max_session_lifetime = 8.hours
    #   end
    #
    # If the max_session_lifetime configuration parameter is nil, the :lifetimed module is not loaded.
    #
    # = Columns
    # * current_sign_in_at - requires `current_sign_in_at` column. This column is managed by the :trackable plugin.
    #
    # = Methods
    # * max_session_lifetime_exceeded? - true if the user's session has exceeded the max lifetime allowed
    #
    #
    module Lifetimed
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:current_sign_in_at]
      end

      # Has the session reached its maximum allowed lifespan?
      def max_session_lifetime_exceeded?
        return false if max_session_lifetime.nil?
        return false if current_sign_in_at.nil?
        current_sign_in_at <= max_session_lifetime.ago
      end

      private

      def max_session_lifetime
        Authenticate.configuration.max_session_lifetime
      end

    end
  end
end
