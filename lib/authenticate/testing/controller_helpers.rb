module Authenticate
  module Testing

    # Helpers for controller tests/specs.
    #
    #
    module ControllerHelpers
      def login_as(user)
        controller.login(user)
      end

      def logout
        controller.logout
      end
    end
  end
end
