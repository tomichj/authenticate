# Authenticate mailer.
#
# Handles password change requests.
class AuthenticateMailer < ActionMailer::Base
  def change_password(user)
    @user = user
    mail from: Authenticate.configuration.mailer_sender,
         to: @user.email,
         subject: I18n.t(:change_password, scope: [:authenticate, :models, :authenticate_mailer])
  end
end
