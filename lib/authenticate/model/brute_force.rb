require 'authenticate/callbacks/brute_force'

module Authenticate
  module Model
    #
    # Protect from brute force attacks. Lock accounts that have too many failed consecutive logins.
    # Todo: email user to allow unlocking via a token.
    #
    # To enable brute force protection, set the config params shown below. Example:
    #
    #   Authenticate.configure do |config|
    #     config.bad_login_lockout_period = 5.minutes
    #     config.max_consecutive_bad_logins_allowed = 3
    #   end
    #
    # = Columns
    # * failed_logins_count - each consecutive failed login increments this counter. Set back to 0 on successful login.
    # * lock_expires_at - datetime a locked account will again become available.
    #
    # = Configuration
    # * max_consecutive_bad_logins_allowed - how many failed logins are allowed?
    # * bad_login_lockout_period - how long is the user locked out? nil indicates forever.
    #
    # = Methods
    # The following methods are added to your user model:
    # * register_failed_login! - increment failed_logins_count, lock account if in violation
    # * lock! - lock the account, setting the lock_expires_at attribute
    # * unlock! - reset failed_logins_count to 0, lock_expires_at to nil
    # * locked? - is the account locked? @return[Boolean]
    # * unlocked? - is the account unlocked? @return[Boolean]
    #
    module BruteForce
      extend ActiveSupport::Concern

      def self.required_fields(_klass)
        [:failed_logins_count, :lock_expires_at]
      end

      def register_failed_login!
        self.failed_logins_count ||= 0
        self.failed_logins_count += 1
        lock! if self.failed_logins_count > max_bad_logins
      end

      def lock!
        update_attribute(:lock_expires_at, Time.now.utc + lockout_period)
      end

      def unlock!
        update_attributes(failed_logins_count: 0, lock_expires_at: nil)
      end

      def locked?
        !unlocked?
      end

      def unlocked?
        lock_expires_at.nil?
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
