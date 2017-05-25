module Authenticate
  module Testing

    # Helpers for controller tests/specs.
    #
    # Example:
    #
    #   describe DashboardsController do
    #     describe '#show' do
    #       it 'shows view' do
    #         user = create(:user)
    #         login_as(user)
    #         get :show
    #         expect(response).to be_success
    #       end
    #     end
    #   end
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
