class MessagesController < ApplicationController
  inherit_resources
  
  before_filter :login_required
  after_filter :user_puls
  
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
  actions :index, :create
  respond_to :html, :only => [:index, :create]
  respond_to :json
  belongs_to :booking
  helper_method :parent
  
  has_scope :last_messages, :as => :last_message
  has_scope :except, :as => :except_chat
  
  def index
    index! do |format|
      format.json { render :json => messages_to_json(collection) }
      format.html
    end
  end
  
  def create
    create! do |format|
      format.json { render :json=> messages_to_json([resource]) }
      format.html { redirect_to collection_url }
    end
  end
  
  def check_messages
    @messages = apply_scopes(current_user.messages) #.except(params[:except_chat]).last_messages(params[:last_message])
    render :json=> messages_to_json(@messages)
  end
  
  protected
  # FIXME: This method is not called by InheritResources
  # We should find the way to disallow user to view message for somebody else's bookings
  def parent
    @booking = Booking.for_user(current_user).find(params[:booking_id])
  end
  
  def create_resource(object)
    object.user_fb_id = current_user.fb_user_id
    object.save
  end
  
  # TODO: Move to model
  def messages_to_json(messages)
    messages.map{|msg|{
      "user_fb_id" => msg.user_fb_id,
       "message_class" => msg.html_class,
       "sent_at" => msg.created_at.to_formatted_s(:short), 
       "message" => msg.message,
       "id" => msg.id,
       "url" => discuss_booking_path(msg.booking)
    }}.to_json
  end
end
