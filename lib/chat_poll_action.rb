class ChatPollAction < Cramp::Action
  before_start :load_booking,:load_user
  on_start :retrieve_chats
  
  def load_booking
    #@booking = Booking.find(params[:booking])
  end
  
  def load_user
    #@user = User.find_by_fb_user_id(params[:user])
  end

  def retrieve_chats 
    # chats = @booking.booking_messages.where(["id > ?",params[:last_message]])
    #     list = chats.map { |msg| { "message_class" => msg.html_class, 
    #                                "sent_at" => msg.created_at.to_formatted_s(:short), 
    #                                "message" => msg.message, 
    #                                "user_fb_id" => msg.user_fb_id } }
    render "Testing"#[list.to_json,"\n"]
    finish
  end
end
