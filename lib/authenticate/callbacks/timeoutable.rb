Authenticate.lifecycle.after_authentication name: 'timeoutable after authentication' do |user, session, options|
  if user && user.respond_to?(:last_access_at)
    user.last_access_at = Time.now.utc
    user.save!
  end
end

Authenticate.lifecycle.after_set_user name: 'timeoutable after set_user', except: :authentication do |user, session, options|
  puts "user.respond_to?(:timedout?) #{user.respond_to?(:timedout?).inspect}" if user
  if user && user.respond_to?(:timedout?)
    throw(:failure, 'Your session has expired') if user.timedout?
    user.last_access_at = Time.now.utc
    user.save!
  end
end
