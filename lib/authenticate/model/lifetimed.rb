require 'authenticate/callbacks/lifetimed'

module Authenticate
  module Model

    # The user session has a maximum allowed lifespan, after which the session is expired and requires
    # re-authentication.
    #
    # = configuration
    #
    # Set the maximum session lifetime in the initializer, giving a timestamp.
    #
    #   Authenticate.configure do |config|
    #     config.max_session_lifetime = 8.hours
    #   end
    #
    # If the max_session_lifetime configuration parameter is nil, the :lifetimed module is not loaded.
    #
    # = columns
    # Requires the `current_sign_in_at` column. This column is managed by the :trackable plugin.
    #
    # = methods
    # - max_session_timedout? - true if the user's session is too old and must be reaped
    #
    #
    module Lifetimed
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:current_sign_in_at]
      end

      # Has the session reached its maximum allowed lifespan?
      def max_session_timedout?
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
