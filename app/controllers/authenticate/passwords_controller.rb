# Request password change via an emailed link with a unique token.
# Thanks to devise and Clearance.
class Authenticate::PasswordsController < Authenticate::AuthenticateController
  skip_before_action :require_authentication, only: [:create, :edit, :new, :update], raise: false
  before_action :ensure_existing_user, only: [:edit, :update]

  # Display screen to request a password change email.
  # GET /users/passwords/new
  def new
    render template: 'passwords/new'
  end

  # Send password change email.
  #
  # POST /users/password
  def create
    if (user = find_user_for_create)
      user.forgot_password!
      deliver_email(user)
    end
    redirect_to sign_in_path, notice: flash_create_description
  end

  # Screen to enter your new password.
  #
  # A get with the token in the url is expected:
  #   GET /users/passwords/3/edit?token=abcdef
  #
  # This results in a redirect with the token removed from the url & copied to the session:
  #   GET /users/passwords/3/edit
  #
  def edit
    @user = find_user_for_edit

    if params[:token]
      session[:password_reset_token] = params[:token]
      redirect_to edit_users_password_url(@user)
    elsif !@user.reset_password_period_valid?
      redirect_to sign_in_path, notice: flash_failure_token_expired
    else
      render template: 'passwords/edit'
    end
  end

  # Save the new password entered in #edit.
  #
  # PUT /users/passwords/3/
  def update
    @user = find_user_for_update

    if !@user.reset_password_period_valid?
      redirect_to sign_in_path, notice: flash_failure_token_expired
    elsif @user.update_password password_reset_params # password changed, log user back in!
      login @user
      redirect_to url_after_update, notice: flash_success_password_changed
    else
      # failed to update password for some reason, perhaps password was too short or otherwise sucked.
      flash.now[:notice] = flash_failure_after_update
      render template: 'passwords/edit'
    end
  end

  private

  def deliver_email(user)
    mail = ::AuthenticateMailer.change_password(user)

    if mail.respond_to?(:deliver_later)
      mail.deliver_later
    else
      mail.deliver
    end
  end

  def password_reset_params
    params[:password_reset][:password]
  end

  def find_user_for_create
    Authenticate.configuration.user_model_class.find_by_normalized_email params[:password][:email]
  end

  def find_user_for_edit
    find_user_by_id_and_password_reset_token
  end

  def find_user_for_update
    find_user_by_id_and_password_reset_token
  end

  def ensure_existing_user
    unless find_user_by_id_and_password_reset_token
      flash.now[:notice] = flash_failure_when_forbidden
      render template: 'passwords/new'
    end
  end

  def find_user_by_id_and_password_reset_token
    token = session[:password_reset_token] || params[:token]
    # Authenticate.configuration.user_model_class.where(id: params[:id], password_reset_token: token).first
    Authenticate.configuration.user_model_class.find_by_id_and_password_reset_token params[:id], token.to_s
  end

  def flash_create_description
    translate(:description,
              scope: [:Authenticate, :controllers, :passwords],
              default: t('passwords.create.description'))
  end

  def flash_success_password_changed
    translate(:success_password_changed,
              scope: [:Authenticate, :controllers, :passwords],
              default: t('flashes.success_password_changed'))
  end

  def flash_failure_token_expired
    translate(:failure_token_expired,
              scope: [:Authenticate, :controllers, :passwords],
              default: t('flashes.failure_token_expired'))
  end

  def flash_failure_when_forbidden
    translate(:forbidden,
              scope: [:Authenticate, :controllers, :passwords],
              default: t('flashes.failure_when_forbidden'))
  end

  def flash_failure_after_update
    translate(:blank_password,
              scope: [:Authenticate, :controllers, :passwords],
              default: t('flashes.failure_after_update'))
  end

  def url_after_create
    sign_in_url
  end

  def url_after_update
    Authenticate.configuration.redirect_url
  end
end
