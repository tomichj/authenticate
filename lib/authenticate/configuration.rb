# Authenticate
module Authenticate
  #
  # Configuration for Authenticate.
  #
  class Configuration
    #
    # ActiveRecord model class name that represents your user. Specify as a String.
    #
    # Defaults to '::User'.
    #
    # To set to a different class:
    #
    #   Authenticate.configure do |config|
    #     config.user_model = 'BlogUser'
    #   end
    #
    # @return [String]
    attr_accessor :user_model

    # Name of the session cookie Authenticate will send to client browser.
    #
    # Defaults to 'authenticate_session_token'.
    #
    # @return [String]
    attr_accessor :cookie_name

    # A lambda called to set the remember token cookie expires attribute.
    #
    # Defaults to 1 year expiration.
    #
    # Note this is NOT the authenticate session's max lifetime, but only the cookie's lifetime.
    #
    # See #max_session_lifetime for more on the session lifetime.
    #
    # To set cookie expiration yourself:
    #
    #   Authenticate.configure do |config|
    #     config.cookie_expiration = { 1.month.from_now.utc }
    #   end
    #
    # @return [Lambda]
    attr_accessor :cookie_expiration

    # The domain to set for the Authenticate session cookie.
    #
    # Defaults to nil, which will cause the cookie domain to set to the domain of the request.
    #
    # @return [String]
    attr_accessor :cookie_domain

    # Controls which paths the session token cookie is valid for.
    #
    # Defaults to `"/"` for the entire domain.
    #
    # For more, see [RFC6265](http://tools.ietf.org/html/rfc6265#section-5.1.4).
    # @return [String]
    attr_accessor :cookie_path

    # Controls whether cookie should be signed with your app's secret.
    #
    # Defaults to `false`.
    #
    # When set to `true`, Authenticate will use Rails 'signed cookie' mechanism to
    # prevent tampering with cookie value.
    #
    # You should have `secret_key_base` set for your environment in `config/secrets.yml`
    # or Authenticate will fallback to default mechanism.
    #
    # For more, see [ActionDispatch::Cookies documentation](http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html).
    # @return [Boolean]
    attr_accessor :signed_cookie

    # Controls whether cookie should be encrypted.
    #
    # Defaults to `false`.
    #
    # When set to `true`, Authenticate will encrypt cookie value using Rails built-in
    # mechanism to prevent tampering with cookie value. In addition, [#signed_cookie] option
    # will be omitted.
    #
    # It differs from [#signed_cookie] in that cookie value will be encrypted before
    # being signed.
    #
    # You should set this value to true in live environments where you can not use
    # [#secure_cookie] (e.g. non-https connections).
    #
    # For more, see [ActionDispatch::Cookies documentation](http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html).
    # @return [Boolean]
    attr_accessor :encrypted_cookie

    # Controls the secure setting on the session cookie.
    #
    # Defaults to `false`.
    #
    # When set to 'true', the browser will only send the cookie to the server over HTTPS.
    # If set to true over an insecure http (not https) connection, the cookie will not
    # be usable and the user will not be successfully authenticated.
    #
    # You should set this value to true in live environments to prevent session hijacking.
    #
    # Set to false in development environments.
    #
    # For more, see [RFC6265](http://tools.ietf.org/html/rfc6265#section-5.2.5).
    # @return [Boolean]
    attr_accessor :secure_cookie

    # Controls whether the  HttpOnly flag should be set on the session cookie.
    # If `true`, the cookie will not be made available to JavaScript.
    #
    # Defaults to `true`.
    #
    # For more see [RFC6265](http://tools.ietf.org/html/rfc6265#section-5.2.6).
    # @return [Boolean]
    attr_accessor :cookie_http_only

    # Controls the 'from' address for Authenticate emails. Set this to a value appropriate to your application.
    #
    # Defaults to reply@example.com.
    #
    # @return [String]
    attr_accessor :mailer_sender

    # Determines what crypto is used when authenticating and setting passwords.
    #
    # Defaults to {Authenticate::Model::BCrypt}.
    #
    # At the moment Bcrypt is the only option offered.
    #
    # Crypto implementations must implement:
    #   * match?(secret, encrypted)
    #   * encrypt(secret)
    #
    # @return [Module #match? #encrypt]
    attr_accessor :crypto_provider

    # Invalidate the session after the specified period of idle time.
    # If the interval between the current access time and the last access time is greater than timeout_in,
    # the session is invalidated. The user will be prompted for authentication again.
    #
    # Defaults to nil, which is no idle timeout.
    #
    #   Authenticate.configure do |config|
    #     config.timeout_in = 45.minutes
    #   end
    #
    # @return [ActiveSupport::CoreExtensions::Numeric::Time]
    attr_accessor :timeout_in

    # Allow a session to 'live' for no more than the given elapsed time, e.g. 8.hours.
    #
    # Defaults to nil, or no max session time.
    #
    # If set, a user session will expire once it has been active for max_session_lifetime.
    # The user session is invalidated and the next access will will prompt the user for authentication.
    #
    # Authenticate.configure do |config|
    #   config.max_session_lifetime = 8.hours
    # end
    #
    # @return [ActiveSupport::CoreExtensions::Numeric::Time]
    attr_accessor :max_session_lifetime

    # Number of consecutive bad login attempts allowed. Commonly called "brute force protection".
    # The user's consecutive bad logins will be tracked, and if they exceed the allowed maximum,
    # the user's account will be locked. The length of the lockout is determined by [#bad_login_lockout_period].
    #
    # Default is nil, which disables this feature.
    #
    # Authenticate.configure do |config|
    #   config.max_consecutive_bad_logins_allowed = 4
    #   config.bad_login_lockout_period = 10.minutes
    # end
    #
    # @return [Integer]
    attr_accessor :max_consecutive_bad_logins_allowed

    # Time period to lock an account for if the user exceeds max_consecutive_bad_logins_allowed.
    #
    # If set to nil, account is locked out indefinitely.
    #
    # @return [ActiveSupport::CoreExtensions::Numeric::Time]
    attr_accessor :bad_login_lockout_period

    # Range requirement for password length.
    #
    # Defaults to `8..128`.
    #
    # @return [Range]
    attr_accessor :password_length

    # Strategy for authentication.
    #
    # Available strategies:
    # * :email - requires user have attribute :email
    # * :username - requires user have attribute :username
    #
    # Defaults to :email. To set to :username:
    #
    #   Configuration.configure do |config|
    #     config.authentication_strategy = :username
    #   end
    #
    # Authenticate is designed to authenticate via :email. Some support for username is included.
    # Username still requires an :email attribute on your User model.
    #
    # Alternatively, you can plug in your own authentication class:
    #
    #   Configuration.configure do |config|
    #     config.authentication_strategy = MyFunkyAuthClass
    #   end
    #
    # @return [Symbol or Class]
    attr_accessor :authentication_strategy

    # The default path Authenticate will redirect signed in users to.
    #
    # Defaults to `"/"`.
    #
    # This can also be overridden for specific scenarios by overriding controller methods that rely on it.
    # @return [String]
    attr_accessor :redirect_url

    # Rotate CSRF token on sign in if true.
    #
    # Defaults to false, but will default to true in 1.0.
    #
    # @return [Boolean]
    attr_accessor :rotate_csrf_on_sign_in

    # Controls whether the "sign up" route, allowing creation of users, is enabled.
    #
    # Defaults to `true`.
    #
    # Set to `false` to disable user creation routes. The setting is ignored if routes are disabled.
    #
    # @return [Boolean]
    attr_writer :allow_sign_up

    # Enable or disable Authenticate's built-in routes.
    #
    # Defaults to 'true'.
    #
    # If you disable the routes, your application is responsible for all routes.
    #
    # You can deploy a copy of Authenticate's routes with `rails generate authenticate:routes`,
    # which will also set `config.routes = false`.
    #
    # @return [Boolean]
    attr_accessor :routes

    # The time period within which the password must be reset or the token expires.
    # If set to nil, the password reset token does not expire.
    #
    # Defaults to `2.days`.
    #
    # @return [ActiveSupport::CoreExtensions::Numeric::Time]
    attr_accessor :reset_password_within

    # An array of additional modules to load into the User module.
    #
    # Defaults to an empty array.
    #
    # @return [Array]
    attr_accessor :modules

    # Enable debugging messages.
    # @private
    # @return [Boolean]
    attr_accessor :debug

    def initialize
      # Defaults
      @debug = false
      @cookie_name = 'authenticate_session_token'
      @cookie_expiration = -> { 1.year.from_now.utc }
      @cookie_domain = nil
      @cookie_path = '/'
      @signed_cookie = false
      @encrypted_cookie = false
      @secure_cookie = false
      @cookie_http_only = true
      @mailer_sender = 'reply@example.com'
      @redirect_url = '/'
      @rotate_csrf_on_sign_in = false
      @allow_sign_up = true
      @routes = true
      @reset_password_within = 2.days
      @modules = []
      @user_model = '::User'
      @authentication_strategy = :email
      @password_length = 8..128
    end

    def user_model_class
      @user_model_class ||= user_model.constantize
    end

    # The routing key for user routes. See `routes.rb`.
    # @return [Symbol]
    def user_model_route_key
      return :users if @user_model == '::User' # avoid nil in generator
      user_model_class.model_name.route_key
    end

    # The key for accessing user parameters.
    # @return [Symbol]
    def user_model_param_key
      return :user if @user_model == '::User' # avoid nil in generator
      user_model_class.model_name.param_key.to_sym
    end

    # Actions allowed for :user resources (in routes.rb).
    # If sign up is allowed, the [:create] action is allowed, otherwise [].
    # @return [Array<Symbol>]
    def user_actions
      allow_sign_up? ? [:create] : []
    end

    # Is the user sign up route enabled?
    # @return [Boolean]
    def allow_sign_up?
      @allow_sign_up
    end

    # @return [Boolean] are Authenticate's built-in routes enabled?
    def routes_enabled?
      @routes
    end

    def rotate_csrf_on_sign_in?
      rotate_csrf_on_sign_in
    end

    # List of symbols naming modules to load.
    def modules
      modules = @modules.dup # in case the user pushes any on
      modules << @authentication_strategy
      modules << :db_password
      modules << :password_reset
      modules << :trackable  # needs configuration
      modules << :timeoutable if @timeout_in
      modules << :lifetimed if @max_session_lifetime
      modules << :brute_force if @max_consecutive_bad_logins_allowed
      modules
    end
  end # end of Configuration class
  #
  # Access to Authenticate's configuration, e.g.:
  #
  #   puts Authenticate.configuration.redirect_url
  #
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
