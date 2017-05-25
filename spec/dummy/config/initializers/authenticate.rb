Authenticate.configure do |config|
  config.timeout_in = 45.minutes
  config.max_session_lifetime = 20.minutes
  config.max_consecutive_bad_logins_allowed = 2
  config.bad_login_lockout_period = 10.minutes
  config.reset_password_within = 5.minutes
  config.password_length = 8..128
  config.debug = true
end
