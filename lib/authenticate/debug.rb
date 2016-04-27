module Authenticate
  #
  # Simple debug output for gem.
  #
  module Debug
    extend ActiveSupport::Concern

    def debug(msg)
      if defined?(Rails) && defined?(Rails.logger) && Authenticate.configuration.debug
        Rails.logger.info msg.to_s
      elsif Authenticate.configuration.debug
        puts msg.to_s
      end
    end
  end
end
