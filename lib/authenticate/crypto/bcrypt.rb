module Authenticate
  module Crypto

    # All crypto providers must implement encrypt(secret) and match?(secret, encrypted)
    module BCrypt
      require 'bcrypt'

      def encrypt(secret)
        ::BCrypt::Password.create secret, cost: cost
      end

      def match?(secret, encrypted)
        return false unless encrypted.present?
        ::BCrypt::Password.new(encrypted) == secret
      end

      def cost
        @cost ||= ::BCrypt::Engine::DEFAULT_COST
      end

      def cost=(val)
        if val < ::BCrypt::Engine::MIN_COST
          raise ArgumentError.new("bcrypt cost cannot be set below the engine's min cost (#{::BCrypt::Engine::MIN_COST})")
        end
        @cost = val
      end

    end
  end
end
