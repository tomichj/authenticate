#
# Controller to create new users.
#
class Authenticate::UsersController < Authenticate::AuthenticateController
  before_action :redirect_signed_in_users, only: [:create, :new]
  skip_before_action :require_login, only: [:create, :new], raise: false
  skip_before_action :require_authentication, only: [:create, :new], raise: false

  def new
    @user = user_from_params
    render template: 'users/new'
  end

  def create
    @user = user_from_params

    if @user.save
      login @user
      redirect_back_or url_after_create
    else
      render template: 'users/new'
    end
  end

  private

  def redirect_signed_in_users
    redirect_to Authenticate.configuration.redirect_url if logged_in?
  end

  def url_after_create
    Authenticate.configuration.redirect_url
  end

  def user_from_params
    email = user_params.delete(:email)
    password = user_params.delete(:password)

    Authenticate.configuration.user_model_class.new(user_params).tap do |user|
      user.email = email
      user.password = password
    end
  end

  def user_params
    params[Authenticate.configuration.user_model_param_key] || {}
  end
end
