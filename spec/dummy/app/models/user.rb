class User < ActiveRecord::Base
  include Authenticate::User
end
