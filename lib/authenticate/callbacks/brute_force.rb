# Prevents a locked user from logging in, and unlocks users that expired their lock time.
# Runs as a hook after authentication.
Authenticate.lifecycle.prepend_after_authentication name: 'brute force protection' do |user, session, options|
  include ActionView::Helpers::DateHelper

  # puts 'bf: about to check authentication'
  unless session.authenticated?
    # puts 'bf: session not authenticated'

    user_credentials = User.credentials(session.request.params)
    # puts "brute force protection user_credentials: #{user_credentials}"
    user ||= User.find_by_credentials(user_credentials)

    # puts 'bf: looked up user by credentials, found:' + user.inspect
    if user
      # puts 'found user, about to register failed attempt'
      user.register_failed_login!
      user.save!
    end
  end

  # if user is locked, and we allow a lockout period, then unlock the user if they've waited
  # longer than the lockout period.
  if user && user.locked? && Authenticate.configuration.bad_login_lockout_period != nil
    user.unlock! if user.lock_expires_at <= Time.now.utc
  end

  if user && user.locked?
    remaining = time_ago_in_words(user.lock_expires_at)
    throw(:failure, "Your account is locked, will unlock in #{remaining.to_s}")
  end

end
