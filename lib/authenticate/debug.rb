module Authenticate
  module Debug
    extend ActiveSupport::Concern

    def d(msg)
      Rails.logger.info msg.to_s if Authenticate.configuration.debug
    end

  end
end
