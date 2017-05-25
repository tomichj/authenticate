module Authenticate
  #
  # The authenticate controller methods.
  #
  # Typically, you include this concern into your ApplicationController. A basic implementation might look like this:
  #
  #    class ApplicationController < ActionController::Base
  #       include Authenticate::Controller
  #       before_action :require_login
  #       protect_from_forgery with: :exception
  #     end
  #
  # Methods, generally called from authenticate's app controllers:
  # * authenticate(params) - validate a user's identity
  # * login(user, &block) - complete login after validating a user's identity, creating an Authenticate session
  # * logout - log a user out, invalidating their Authenticate session.
  #
  # Action/Filter:
  # * require_authentication - restrict access to authenticated users, often from ApplicationController
  #
  # Helpers, used anywhere:
  # * current_user - get the currently logged in user
  # * logged_in? - is the user logged in?
  # * logged_out? - is the user not logged in?
  #
  module Controller
    extend ActiveSupport::Concern
    include Debug

    included do
      helper_method :current_user, :logged_in?, :logged_out?, :authenticated?
      attr_writer :authenticate_session
    end

    # Validate a user's identity with (typically) email/ID & password, and return the User if valid, or nil.
    # After calling this, call login(user) to complete the process.
    def authenticate(params)
      credentials = Authenticate.configuration.user_model_class.credentials(params)
      Authenticate.configuration.user_model_class.authenticate(credentials)
    end

    # Complete the user's sign in process: after calling authenticate, or after user creates account.
    # Runs all valid callbacks and sends the user a session token.
    def login(user, &block)
      authenticate_session.login user, &block

      if logged_in? && Authenticate.configuration.rotate_csrf_on_sign_in?
        session.delete(:_csrf_token)
        form_authenticity_token
      end
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
      authenticate_session.logout
    end

    # Use this filter as a before_action to control access to controller actions,
    # limiting to logged in users.
    #
    # Placing in application_controller will control access to all controllers.
    #
    # Example:
    #
    #   class ApplicationController < ActionController::Base
    #     before_action :require_login
    #
    #     def index
    #       # ...
    #     end
    #   end
    #
    def require_login
      debug "!!!!!!!!!!!!!!!!!! controller#require_login " # logged_in? #{logged_in?}"
      unauthorized unless logged_in?
      message = catch(:failure) do
        current_user = authenticate_session.current_user
        Authenticate.lifecycle.run_callbacks(:after_set_user, current_user, authenticate_session, event: :set_user)
      end
      unauthorized(message) if message
    end

    # Has the user been logged in? Exposed as a helper, can be called from views.
    #
    #   <% if logged_in? %>
    #     <%= link_to sign_out_path, "Sign out" %>
    #   <% else %>
    #     <%= link_to sign_in_path, "Sign in" %>
    #   <% end %>
    #
    def logged_in?
      debug "!!!!!!!!!!!!!!!!!! controller#logged_in?"
      authenticate_session.logged_in?
    end

    # Has the user not logged in? Exposed as a helper, can be called from views.
    #
    #   <% if logged_out? %>
    #     <%= link_to sign_in_path, "Sign in" %>
    #   <% end %>
    #
    def logged_out?
      !logged_in?
    end

    # Get the current user from the current Authenticate session.
    # Exposed as a helper , can be called from controllers, views, and other helpers.
    #
    #   <p>Your email address: <%= current_user.email %></p>
    #
    def current_user
      authenticate_session.current_user
    end

    # Return true if it's an Authenticate controller. Useful if you want to apply a before
    # filter to all controllers, except the ones in Authenticate, e.g.
    #
    #   before_action :my_filter, unless: :authenticate_controller?
    #
    def authenticate_controller?
      is_a?(Authenticate::AuthenticateController)
    end

    # The old API.
    #
    # todo: remove in a future version.
    def require_authentication
      warn "#{Kernel.caller.first}: [DEPRECATION] " +
        "'require_authentication' is deprecated and will be removed in a future release. use 'require_login' instead"
      require_login
    end

    # The old API.
    #
    # todo: remove in a future version.
    def authenticated?
      warn "#{Kernel.caller.first}: [DEPRECATION] " +
             "'authenticated?' is deprecated and will be removed in a future release. Use 'logged_in?' instead."
      logged_in?
    end

    protected

    # User is not authorized, bounce 'em to sign in
    def unauthorized(msg = t('flashes.failure_when_not_signed_in'))
      authenticate_session.logout
      respond_to do |format|
        format.any(:js, :json, :xml) { head :unauthorized }
        format.any { redirect_unauthorized(msg) }
      end
    end

    def redirect_unauthorized(flash_message)
      store_location!

      if flash_message
        flash[:notice] = flash_message # TODO: use locales
      end

      if logged_in?
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

    # Write location to return to in user's session (normally a cookie).
    def store_location!
      if request.get?
        session[:authenticate_return_to] = request.original_fullpath
      end
    end

    def stored_location
      session[:authenticate_return_to]
    end

    def clear_stored_location
      session[:authenticate_return_to] = nil
    end

    def authenticate_session
      @authenticate_session ||= Authenticate::Session.new(request)
    end
  end
end
