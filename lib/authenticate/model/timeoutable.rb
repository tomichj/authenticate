require 'authenticate/callbacks/timeoutable'

module Authenticate
  module Model

    # Expire user sessions that have not been accessed within a certain period of time.
    # Expired users will be asked for credentials again.
    #
    # = Columns
    #
    # This module expects and tracks this column on your user model:
    # * last_access_at - datetime of the last access by the user
    #
    # = Configuration
    #
    # * timeout_in - maximum idle time allowed before session is invalidated. nil shuts off this feature.
    #
    # Timeoutable is enabled and configured with the `timeout_in` configuration parameter.
    # `timeout_in` expects a timestamp. Example:
    #
    #   Authenticate.configure do |config|
    #     config.timeout_in = 15.minutes
    #   end
    #
    # You must specify a non-nil timeout_in in your initializer to enable Timeoutable.
    #
    # = Methods
    # * timedout? - has this user timed out? @return[Boolean]
    # * timeout_in - look up timeout period in config, @return [ActiveSupport::CoreExtensions::Numeric::Time]
    #
    module Timeoutable
        extend ActiveSupport::Concern

        def self.required_fields(klass)
          [:last_access_at]
        end

        # Checks whether the user session has expired based on configured time.
        def timedout?
          return false if timeout_in.nil?
          return false if last_access_at.nil?
          last_access_at <= timeout_in.ago
        end

        private

        def timeout_in
          Authenticate.configuration.timeout_in
        end
      end
  end
end
