require 'authenticate/login_status'
require 'authenticate/debug'

module Authenticate
  # Represents an Authenticate session.
  class Session
    include Debug

    attr_accessor :request

    def initialize(request, cookies)
      @request = request # trackable module accesses request
      @cookies = cookies
      @session_token = @cookies[cookie_name]
      debug 'SESSION initialize: @session_token: ' + @session_token.inspect
    end

    # Finish user login process, *after* the user has been authenticated.
    # Called when user creates an account or signs back into the app.
    # Runs all callbacks checking for any login failure. If a login failure
    # occurs, user is NOT logged in.
    #
    # @return [User]
    def login(user)
      @current_user = user
      @current_user.generate_session_token if user.present?

      message = catch(:failure) do
        Authenticate.lifecycle.run_callbacks(:after_set_user, @current_user, self, event: :authentication)
        Authenticate.lifecycle.run_callbacks(:after_authentication, @current_user, self, event: :authentication)
      end

      status = message.present? ? Failure.new(message) : Success.new
      if status.success?
        @current_user.save
        write_cookie if @current_user.session_token
      else
        @current_user = nil
      end

      yield(status) if block_given?
    end

    # Get the user represented by this session.
    #
    # @return [User]
    def current_user
      debug 'session.current_user'
      @current_user ||= load_user if @session_token.present?
      @current_user
    end

    # Has this session successfully authenticated?
    #
    # @return [Boolean]
    def authenticated?
      debug 'session.authenticated?'
      current_user.present?
    end

    # Invalidate the session token, unset the current user and remove the cookie.
    #
    # @return [void]
    def deauthenticate
      # nuke session_token in db
      current_user.reset_session_token! if current_user.present?

      # nuke notion of current_user
      @current_user = nil

      # # nuke cookie
      @cookies.delete cookie_name
    end

    protected

    def user_loaded?
      !@current_user.present?
    end

    private

    def write_cookie
      cookie_hash = {
        path: Authenticate.configuration.cookie_path,
        secure: Authenticate.configuration.secure_cookie,
        httponly: Authenticate.configuration.cookie_http_only,
        value: @current_user.session_token,
        expires: Authenticate.configuration.cookie_expiration.call
      }
      cookie_hash[:domain] = Authenticate.configuration.cookie_domain if Authenticate.configuration.cookie_domain
      # Consider adding an option for a signed cookie
      @cookies[cookie_name] = cookie_hash
    end

    def cookie_name
      Authenticate.configuration.cookie_name.freeze.to_sym
    end

    def load_user
      Authenticate.configuration.user_model_class.where(session_token: @session_token).first
    end
  end
end
