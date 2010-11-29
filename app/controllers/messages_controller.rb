class MessagesController < InheritedResources::Base
  before_filter :oauth_obj,:except=>[:post_chat,:poll_chat,:check_messages]
  before_filter :login_required,:except=>[:post_chat,:poll_chat,:check_messages]
  
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
  respond_to :html
  actions :create
  belongs_to :booking
  
  def create
    create!(:location => discuss_booking_path(parent), :notice => "Message created.")
  end
  
  def post_chat 
    current_user = User.find_by_fb_user_id(params[:booking_message][:fb_user_id])
    current_user.pulse!
    @booking = Booking.find(params[:booking_message][:booking_id])
    message= BookingMessage.create!(:user_fb_id=>current_user.fb_user_id,:booking_id=>@booking.id,:message=>params[:booking_message][:message])
    other = @booking.other_user_than(current_user)
    if other
      message.update_attributes!(:recipient=>other)
      other.deliver_message!("You have a new message in HereStay: #{mobile_discuss_booking_url(@booking.id,:user_id=>other.id)}")
    end
    list = [message]
    list = list.map { |msg| { "user_fb_id" => msg.user_fb_id,
                               "message_class" => msg.html_class, 
                              "sent_at" => msg.created_at.to_formatted_s(:short), 
                              "message" => msg.message,
                              "id" => msg.id} }
    render :json=> list.to_json
  end
  
  def poll_chat
    @booking = Booking.find(params[:booking])
    current_user = User.find_by_fb_user_id(params[:user])
    current_user.pulse!
    chats = []
    if params[:last_message].blank?
      chats = @booking.booking_messages
    else
      chats = @booking.booking_messages.where(["id > ?",params[:last_message]])
    end
    @list = chats.map { |msg| { "message_class" => msg.html_class, 
                               "sent_at" => msg.created_at.to_formatted_s(:short), 
                               "message" => msg.message, 
                               "user_fb_id" => msg.user_fb_id,
                               "id" => msg.id } }
    render :json=>@list.to_json
  end
  
  def check_messages
    current_user = User.find_by_fb_user_id(params[:user])
    current_user.pulse!
    chats = []
    if params[:last_message].blank?
      chats = current_user.booking_messages
    else
      chats = current_user.booking_messages.where(["id > ?",params[:last_message]])
    end
    @list = chats.map { |msg| { "sent_at" => msg.created_at.to_formatted_s(:short), 
                               "message" => msg.message, 
                               "id" => msg.id,
                               "url" => discuss_booking_url(msg.booking) } }
    render :json=>@list.to_json
  end
  
  protected
  
  def create_resource(object)
    object.user_fb_id = current_user.fb_user_id
    object.save
  end
end
