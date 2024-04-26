class UserMailer < ApplicationMailer
  def payment_failed(user)
    @user = user
    mail(to: @user.email, subject: 'Payment Failed')
  end
end
