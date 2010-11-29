class MessagesController < InheritedResources::Base
  before_filter :oauth_obj
  before_filter :login_required
  before_filter :user_puls
  
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
  respond_to :html
  #actions :create
  belongs_to :booking
  
  def index
    chats = booking.booking_messages.last_messages(params[:last_message])
    render :json=> messages_to_json(chats)
  end
  
  def create
    message = booking.booking_messages.create(params[:booking_message].merge({:user_fb_id=>current_user.fb_user_id}))
    render :json=> messages_to_json([message])
  end
  
  def check_messages
    chats = current_user.messages.except(params[:except_chat]).last_messages(params[:last_message])
    render :json=> messages_to_json(chats)
  end
  
  protected
    
  def booking
    @booking ||= Booking.where(["id = ? AND (owner_fb_id = ? OR renter_fb_id = ?) ", params[:booking_id], current_user.fb_user_id, current_user.fb_user_id]).first
  end
  
  def messages_to_json(messages)
    list = messages.map { |msg| { "user_fb_id" => msg.user_fb_id,
                           "message_class" => msg.html_class, 
                           "sent_at" => msg.created_at.to_formatted_s(:short), 
                           "message" => msg.message,
                           "id" => msg.id,
                           "url" => discuss_booking_path(msg.booking) } }
    list.to_json
  end
  
  def user_puls
    current_user.pulse!
  end
end
