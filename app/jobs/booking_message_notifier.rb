class BookingMessageNotifier
  def initialize(message)
    @message_id = message.id
  end
  
  def perform
    message = BookingMessage.find(@message_id)
    booking = message.booking
    if message.user_fb_id == booking.owner_fb_id
      UserMailer.renter_message_notification(message).deliver
    else
      UserMailer.owner_message_notification(message).deliver
    end
  end
end