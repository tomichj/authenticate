Authenticate.configure do |config|
  config.rotate_csrf_on_sign_in = true

  # config.user_model = 'User'
  # config.cookie_name = 'authenticate_session_token'
  # config.cookie_expiration = { 1.month.from_now.utc }
  # config.cookie_domain = nil
  # config.cookie_path = '/'
  # config.secure_cookie = false   # set to true in production https environments
  # config.cookie_http_only = false # set to true if you can
  # config.mailer_sender = 'reply@example.com'
  # config.crypto_provider = Authenticate::Model::BCrypt
  # config.timeout_in = 45.minutes
  # config.max_session_lifetime = 8.hours
  # config.max_consecutive_bad_logins_allowed = 4
  # config.bad_login_lockout_period = 10.minutes
  # config.password_length = 8..128
  # config.authentication_strategy = :email
  # config.redirect_url = '/'
  # config.allow_sign_up = true
  # config.routes = true
  # config.reset_password_within = 2.days
  # config.modules = []
end
