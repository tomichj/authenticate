# Hacky monkey patch, do later deliveries right now, so
class ActionMailer::MessageDelivery
  def deliver_later
    deliver_now
  end
end
