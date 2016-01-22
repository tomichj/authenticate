# After each sign in: ”update sign in time, sign in count and sign in IP.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication.
Authenticate.lifecycle.after_authentication name: 'trackable' do |user, session, options|
  if user.respond_to?(:update_tracked_fields!)
    user.update_tracked_fields!(session.request)
  end
end
