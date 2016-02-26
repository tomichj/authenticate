require 'authenticate/controller'

module Controllers
  module ControllerHelpers

    def sign_in
      user = create(:user)
      sign_in_as user
    end

    def sign_in_as(user)
      controller.login user
    end

    def sign_out
      controller.logout
    end

  end
end

RSpec.configure do |config|
  config.include Controllers::ControllerHelpers, type: :controller
end
