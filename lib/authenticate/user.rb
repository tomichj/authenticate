require 'authenticate/configuration'
require 'authenticate/token'
require 'authenticate/callbacks/authenticatable'

module Authenticate

  # Required to be included in your configued user class, which is `User` by
  # default, but can be changed with {Configuration#user_model=}.
  #
  #   class User
  #     include Authenticate::User
  #     # ...
  #   end
  #
  # To change the user class from the default User, assign it :
  #
  #   Authenticate.configure do |config|
  #     config.user_model = 'MyPackage::Gundan'
  #   end
  #
  # The fields and methods included by Authenticate::User will depend on what modules you have included in your
  # configuration. When your user class is loaded, User will load any modules at that time. If you have another
  # initializer that loads User before Authenticate's initializer has run, this may cause interfere with the
  # configuration of your user.
  #
  # Every user will have two methods to manage session tokens:
  # - generate_session_token - generates and sets the Authenticate session token
  # - reset_session_token! - calls generate_session_token and save! immediately
  #
  module User
    extend ActiveSupport::Concern

    included do
      include Modules
      load_modules
    end

    # Generate a new session token for the user, overwriting the existing session token, if any.
    # This is not automatically persisted; call {#reset_session_token!} to automatically
    # generate and persist the session token update.
    def generate_session_token
      self.session_token = Authenticate::Token.new
    end

    # Generate a new session token and persist the change, ignoring validations.
    # This effectively signs out all existing sessions. Called as part of logout.
    def reset_session_token!
      generate_session_token
      save validate: false
    end

    module ClassMethods

      def normalize_email(email)
        email.to_s.downcase.gsub(/\s+/, '')
      end

      # We need to find users by email even if they don't use email to log in
      def find_by_normalized_email(email)
        find_by_email normalize_email(email)
      end

      end

  end
end

