class OrderMailer < ApplicationMailer
  def reviewed(order)
    @order = order
    mail(
      to: order.user.email,
      subject: "We've Reviewed Your Order at #{APP_CONFIG['title']}"
    )
  end

  def created(order)
    @order = order
    mail(
      to: order.user.email,
      subject: "We've Received Your Order at #{APP_CONFIG['title']}"
    )
  end
end
