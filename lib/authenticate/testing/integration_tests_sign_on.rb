module Authenticate
  module Testing

    # Middleware which allows tests to bypass your sign on screen.
    # Typically used by integration and feature tests, etc.
    # Speeds up these tests by eliminating the need to visit and
    # submit the signon form repeatedly.
    #
    # Sign a test user in by passing as=USER_ID in a query parameter.
    # If `User#to_param` is overridden you may pass a block to override
    # the default user lookup behaviour.
    #
    # Configure your application's test environment as follows:
    #
    #   # config/environments/test.rb
    #   MyRailsApp::Application.configure do
    #     # ...
    #     config.middleware.use Authenticate::IntegrationTestsSignOn
    #     # ...
    #   end
    #
    # or if `User#to_param` is overridden (to `username` for example):
    #
    #   # config/environments/test.rb
    #   MyRailsApp::Application.configure do
    #     # ...
    #     config.middleware.use Authenticate::IntegrationTestsSignOn do |username|
    #       User.find_by(username: username)
    #     end
    #     # ...
    #   end
    #
    # After configuring your app, usage in an integration tests is simple:
    #
    #   user = ... # load user
    #   visit dashboard_path(as: user)
    #
    class IntegrationTestsSignOn
      def initialize(app, &block)
        @app = app
        @block = block
      end

      def call(env)
        do_sign_on(env)
        @app.call(env)
      end

      private

      def do_sign_on(env)
        params = Rack::Utils.parse_query(env['QUERY_STRING'])
        user_param = params['as']

        user = find_user(user_param) if user_param.present?
        if user.present?
          user.generate_session_token && user.save if user.session_token.nil?
          request = Rack::Request.new(env)
          request.cookies[Authenticate.configuration.cookie_name] = user.session_token
        end
      end

      def find_user(user_param)
        if @block
          @block.call(user_param)
        else
          Authenticate.configuration.user_model_class.find(user_param)
        end
      end
    end
  end
end
