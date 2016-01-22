puts '************************** initializer start'
Authenticate.configure do |config|
  config.debug = true
  config.timeout_in = 5.minutes
  config.max_session_lifetime = 10.minutes
end
puts '************************** initializer finished'
