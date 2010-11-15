class MessagesController < InheritedResources::Base
  before_filter :oauth_obj,:except=>[:post_chat,:poll_chat]
  before_filter :login_required,:except=>[:post_chat,:poll_chat]
  
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
  respond_to :html
  actions :create
  belongs_to :booking
  
  def create
    create!(:location => discuss_booking_path(parent), :notice => "Message created.")
  end
  
  def post_chat 
    @user = User.find_by_fb_user_id(params[:booking_message][:fb_user_id])
    @user.pulse!
    @booking = Booking.find(params[:booking_message][:booking_id])
    other = @booking.other_user_than(@user)
    message= BookingMessage.create!(:user_fb_id=>@user.fb_user_id,:booking_id=>@booking.id,:message=>params[:booking_message][:message])
    other.deliver_message!("You have a new message in HereStay: #{mobile_discuss_booking_url(@booking.id)}")
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
    @user = User.find_by_fb_user_id(params[:user])
    @user.pulse!
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
  
  protected
  
  def create_resource(object)
    object.user_fb_id = @user.fb_user_id
    object.save
  end
end
