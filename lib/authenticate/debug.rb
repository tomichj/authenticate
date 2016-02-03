module Authenticate
  module Debug
    extend ActiveSupport::Concern


    def debug(msg)
      if defined?(Rails) && defined?(Rails.logger)
        Rails.logger.info msg.to_s if Authenticate.configuration.debug
      else
        puts msg.to_s if Authenticate.configuration.debug
      end
    end


  end
end
