class Authenticate::UsersController < Authenticate::AuthenticateController
  before_action :redirect_signed_in_users, only: [:create, :new]
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
    if authenticated?
      redirect_to Authenticate.configuration.redirect_url
    end
  end

  def url_after_create
    Authenticate.configuration.redirect_url
  end

  def user_from_params
    param_key = Authenticate.configuration.user_model_param_key.to_sym # :user, :user_profile, etc
    user_params = params[param_key] ? user_params(param_key) : Hash.new
    Authenticate.configuration.user_model_class.new(user_params)
  end

  # Override this method to allow additional user attributes.
  # Default impl allows username and email to service both styles of authentication.
  #
  # * param_key - String used for parameter names, ActiveModel::Naming.param_key
  #
  def user_params(param_key)
    params.require(param_key).permit(:username, :email, :password)
  end
end
