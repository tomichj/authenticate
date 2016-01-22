require 'authenticate/callbacks/brute_force'

module Authenticate
  module Model


    # Protect from brute force attacks.
    # Lock accounts that have too many failed consecutive logins.
    # Todo: email user to allow faster unlocking via token.
    module BruteForce
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:failed_logins_count, :lock_expires_at]
      end


      def register_failed_login!
        self.failed_logins_count ||= 0
        self.failed_logins_count += 1
        lock! if self.failed_logins_count >= max_bad_logins
      end

      def lock!
        self.update_attribute(:lock_expires_at, Time.now.utc + lockout_period)
      end

      def unlock!
        self.update_attributes({failed_logins_count: 0, lock_expires_at: nil})
      end

      def locked?
        !unlocked?
      end

      def unlocked?
        self.lock_expires_at.nil?
      end

      private

      def max_bad_logins
        Authenticate.configuration.max_consecutive_bad_logins_allowed
      end

      def lockout_period
        Authenticate.configuration.bad_login_lockout_period
      end
    end
  end
end
