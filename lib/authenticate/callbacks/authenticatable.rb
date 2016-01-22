# If user failed to authenticate, toss them out.
Authenticate.lifecycle.after_authentication name: 'authenticatable' do |user, session, opts|
  throw(:failure, 'Wrong email or password.') unless session.authenticated?
end
