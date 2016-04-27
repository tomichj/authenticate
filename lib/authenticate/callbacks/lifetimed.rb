# Catch sessions that have been live for too long and kill them, forcing the user to reauthenticate.
Authenticate.lifecycle.after_set_user name: 'lifetimed after set_user',
                                      except: :authentication do |user, _session, _options|
  if user && user.respond_to?(:max_session_lifetime_exceeded?)
    throw(:failure, I18n.t('callbacks.lifetimed.failure')) if user.max_session_lifetime_exceeded?
  end
end
