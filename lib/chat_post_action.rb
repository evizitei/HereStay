class ChatPostAction < Cramp::Action
  #before_start :setup_params,:load_user,:load_booking
  on_start :post_chat
  
  # def setup_params
  #   log "DEBUG INFO: -- > #{request.params.inspect}"
  #   @params = request.params
  #   yield
  # end
  # 
  # def load_user
  #   @user = User.find(@params[:booking_message][:fb_user_id])
  #   yield
  # end
  # 
  # def load_booking
  #   @booking = Booking.find(@params[:booking_message][:booking_id])
  #   yield
  # end

  def post_chat 
    @params = request.params
    log("params are #{@params.inspect}")
    @user = User.find(@params[:booking_message][:fb_user_id])
    @booking = Booking.find(@params[:booking_message][:booking_id])
    message= BookingMessage.create!(:user_fb_id=>@user.fb_user_id,:booking_id=>@booking.id,:message=>params[:booking_message][:message])
    list = [message].map { |msg| { "message_class" => msg.html_class, 
                                        "sent_at" => msg.created_at.to_formatted_s(:short), 
                                            "message" => msg.message, 
                                            "user_fb_id" => msg.user_fb_id } }
    render [list.to_json,"\n"]
    finish
  end

  def log(message)
    Cramp.logger.debug(message)
  end
  
  
end
