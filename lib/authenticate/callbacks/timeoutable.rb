# Update last_access_at on every authentication
Authenticate.lifecycle.after_authentication name: 'timeoutable after authentication' do |user, session, options|
  if user && user.respond_to?(:last_access_at)
    user.last_access_at = Time.now.utc
    user.save!
  end
end

# Fail users that have timed out. Otherwise update last_access_at.
Authenticate.lifecycle.after_set_user name: 'timeoutable after set_user', except: :authentication do |user, session, options|
  if user && user.respond_to?(:timedout?)
    throw(:failure, I18n.t('callbacks.timeoutable.failure')) if user.timedout?
    user.last_access_at = Time.now.utc
    user.save!
  end
end
