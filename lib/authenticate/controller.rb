module Authenticate
  module Controller
    extend ActiveSupport::Concern
    include Debug

    included do
      helper_method :current_user, :authenticated?
      attr_writer :authenticate_session
    end


    # Validate a user's identity with (typically) email/ID & password, and return the User if valid, or nil.
    # After calling this, call login(user) to complete the process.
    def authenticate(params)
      # todo: get params from User model
      user_credentials = Authenticate.configuration.user_model_class.credentials(params)
      puts "Controller::user_credentials: #{user_credentials.inspect}"
      Authenticate.configuration.user_model_class.authenticate(user_credentials)
    end


    # Complete the user's sign in process: after calling authenticate, or after user creates account.
    # Runs all valid callbacks and sends the user a session token.
    def login(user, &block)
      authenticate_session.login user, &block
    end


    # Log the user out. Typically used in session controller.
    #
    # class SessionsController < ActionController::Base
    #   include Authenticate::Controller
    #
    #   def destroy
    #     logout
    #     redirect_to '/', notice: 'You logged out successfully'
    #   end
    def logout
      authenticate_session.deauthenticate
    end


    # Use this as a before_action to restrict controller actions to authenticated users.
    # Consider using in application_controller to restrict access to all controllers.
    #
    # Example:
    #
    #   class ApplicationController < ActionController::Base
    #     before_action :require_authentication
    #
    #     def index
    #       # ...
    #     end
    #   end
    #
    def require_authentication
      d 'Controller::require_authentication'
      unless authenticated?
        unauthorized
      end

      message = catch(:failure) do
        current_user = authenticate_session.current_user
        Authenticate.lifecycle.run_callbacks(:after_set_user, current_user, authenticate_session, {event: :set_user })
      end
      unauthorized(message) if message
    end


    # Has the user been logged in? Exposed as a helper, can be called from views.
    #
    #   <% if authenticated? %>
    #     <%= link_to logout_path, "Sign out" %>
    #   <% else %>
    #     <%= link_to login_path, "Sign in" %>
    #   <% end %>
    #
    def authenticated?
      authenticate_session.authenticated?
    end


    # Get the current user from the current Authenticate session.
    # Exposed as a helper , can be called from controllers, views, and other helpers.
    #
    #   <p>Your email address: <%= current_user.email %></p>
    #
    def current_user
      authenticate_session.current_user
    end

    private

    def authenticate_session
      @authenticate_session ||= Authenticate::Session.new(request, cookies)
    end

    def unauthorized(msg = 'You must sign in')
      respond_to do |format|
        format.any(:js, :json, :xml) { head :unauthorized }
        format.any {
          flash[:notice] = msg  # TODO use locales
          redirect_to '/authenticate' #TODO something better baby
        }
      end
    end


  end
end
