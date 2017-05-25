# Prevents a locked user from logging in, and unlocks users that expired their lock time.
# Runs as a hook after authentication.
Authenticate.lifecycle.prepend_after_authentication name: 'brute force protection' do |user, session, _options|
  include ActionView::Helpers::DateHelper
  unless session.logged_in? || Authenticate.configuration.max_consecutive_bad_logins_allowed.nil?
    user_credentials = User.credentials(session.request.params)
    user ||= User.find_by_credentials(user_credentials)
    if user && user.respond_to?(:register_failed_login!)
      user.register_failed_login!
      user.save!
    end
  end

  # if user is locked, and we allow a lockout period, then unlock the user if they've waited
  # longer than the lockout period.
  if user && user.respond_to?(:locked?) && user.locked? && !Authenticate.configuration.bad_login_lockout_period.nil?
    user.unlock! if user.lock_expires_at <= Time.now.utc
  end

  # if the user is still locked, let them know how long they are locked for.
  if user && user.respond_to?(:locked?) && user.locked?
    remaining = time_ago_in_words(user.lock_expires_at)
    throw(:failure, I18n.t('callbacks.brute_force.failure', time_remaining: remaining.to_s))
  end
end
