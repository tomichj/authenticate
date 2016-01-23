module Authenticate
  module Debug
    extend ActiveSupport::Concern

    def d(msg)
      # todo check: Rails constant loaded? Authenticate config read? do a puts otherwise
      Rails.logger.info msg.to_s if Authenticate.configuration.debug
    end

  end
end
