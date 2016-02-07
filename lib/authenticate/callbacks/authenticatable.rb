# Callback to check that the session has been authenticated.
#

# If user failed to authenticate, toss them out.
Authenticate.lifecycle.after_authentication name: 'authenticatable' do |user, session, opts|
  throw(:failure, I18n.t('callbacks.authenticatable.failure')) unless session && session.authenticated?
end
