# Catch sessions that have been live for too long and kill them, forcing the user to reauthenticate.
Authenticate.lifecycle.after_set_user name: 'lifetimed after set_user', except: :authentication do |user, session, options|
  if user && user.respond_to?(:max_session_timedout?)
    throw(:failure, "Your session has reached it's maximum allowed lifetime, you must log in again") if user.max_session_timedout?
  end
end
