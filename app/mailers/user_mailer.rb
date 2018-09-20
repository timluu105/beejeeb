class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(
      to: user.email,
      subject: "Welcome to #{APP_CONFIG['title']}"
    )
  end
end
