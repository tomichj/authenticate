#
# Allow authenticate users to log in and log out.
#
class Authenticate::SessionsController < Authenticate::AuthenticateController
  before_action :redirect_signed_in_users, only: [:new]
  skip_before_action :require_login, only: [:create, :new, :destroy], raise: false
  skip_before_action :require_authentication, only: [:create, :new, :destroy], raise: false

  #
  # Render the login screen.
  #
  def new
    render template: 'sessions/new'
  end

  #
  # Log the user in, with the provided name and password.
  #
  def create
    @user = authenticate(params)
    login(@user) do |status|
      if status.success?
        redirect_back_or url_after_create
      else
        flash.now.notice = status.message
        render template: 'sessions/new', status: :unauthorized
      end
    end
  end

  #
  # Log the user out
  #
  def destroy
    logout
    redirect_to url_after_destroy
  end

  private

  def redirect_signed_in_users
    redirect_to url_for_signed_in_users if logged_in?
  end

  def url_after_create
    Authenticate.configuration.redirect_url
  end

  def url_after_destroy
    sign_in_url
  end

  def url_for_signed_in_users
    url_after_create
  end
end
