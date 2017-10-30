require 'authenticate/login_status'
require 'authenticate/debug'

module Authenticate
  # Represents an Authenticate session.
  class Session
    include Debug

    attr_accessor :request

    # Initialize an Authenticate session.
    #
    # The presence of a session does NOT mean the user is logged in; call #logged_in? to determine login status.
    def initialize(request)
      @request = request # trackable module accesses request
      @cookies = request.cookie_jar
      @session_token = @cookies[cookie_name]
      debug 'SESSION initialize: @session_token: ' + @session_token.inspect
    end

    # Finish user login process, *after* the user has been authenticated.
    # The user is authenticated by Authenticate::Controller#authenticate.
    #
    # Called when user creates an account or signs back into the app.
    # Runs all configured callbacks, checking for login failure.
    #
    # If login is successful, @current_user is set and a session token is generated
    # and returned to the client browser.
    # If login fails, the user is NOT logged in. No session token is set,
    # and @current_user will not be set.
    #
    # After callbacks are finished, a {LoginStatus} is yielded to the provided block,
    # if one is provided.
    #
    # @param [User] user login completed for this user
    # @yieldparam [Success,Failure] status result of the sign in operation.
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
      debug "session.current_user #{@current_user.inspect}"
      @current_user ||= load_user_from_session_token if @session_token.present?
      @current_user
    end

    # Has this user successfully logged in?
    #
    # @return [Boolean]
    def logged_in?
      debug "session.logged_in? #{current_user.present?}"
      current_user.present?
    end

    # Invalidate the session token, unset the current user and remove the cookie.
    #
    # @return [void]
    def logout
      # nuke session_token in db
      current_user.reset_session_token! if current_user.present?

      # nuke notion of current_user
      @current_user = nil

      # nuke session_token cookie from the client browser
      @cookies.delete cookie_name
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

    def load_user_from_session_token
      Authenticate.configuration.user_model_class.where(session_token: @session_token).first
    end
  end
end
