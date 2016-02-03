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


    # Use this filter as a before_action to restrict controller actions to authenticated users.
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
      debug 'Controller::require_authentication'
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

    protected

    # User is not authorized, bounce 'em to sign in
    def unauthorized(msg = 'You must sign in') # get default message from locale
      respond_to do |format|
        format.any(:js, :json, :xml) { head :unauthorized }
        format.any {
          redirect_unauthorized(msg)
        }
      end
    end

    def redirect_unauthorized(flash_message)
      store_location

      if flash_message
        flash[:notice] = flash_message  # TODO use locales
      end

      if authenticated?
        redirect_to url_after_denied_access_when_signed_in
      else
        redirect_to url_after_denied_access_when_signed_out
      end
    end


    def redirect_back_or(default)
      redirect_to(stored_location || default)
      clear_stored_location
    end


    # Used as the redirect location when {#unauthorized} is called and there is a
    # currently signed in user.
    #
    # @return [String]
    def url_after_denied_access_when_signed_in
      Authenticate.configuration.redirect_url
    end

    # Used as the redirect location when {#unauthorized} is called and there is
    # no currently signed in user.
    #
    # @return [String]
    def url_after_denied_access_when_signed_out
      sign_in_url
    end

    private

    # Write location to return to in a cookie. This is 12-factor compliant, cloud-safe.
    def store_location
      if request.get?
        value = {
            expires: nil,
            httponly: true,
            path: nil,
            secure: Authenticate.configuration.secure_cookie,
            value: request.original_fullpath
        }
        cookies[:authenticate_return_to] = value
      end
    end

    def stored_location
      cookies[:authenticate_return_to]
    end

    def clear_stored_location
      cookies.delete :authenticate_return_to
    end

    def authenticate_session
      @authenticate_session ||= Authenticate::Session.new(request, cookies)
    end

  end
end
