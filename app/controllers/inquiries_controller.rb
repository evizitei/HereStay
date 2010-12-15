class InquiriesController < ApplicationController
  inherit_resources
  layout 'application'
  before_filter :login_required
  after_filter :user_puls
  
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  actions :index, :create
  respond_to :html, :only => [:index, :create]
  belongs_to :rental_unit, :optional => true
  respond_to :json
  
  has_scope :last_messages, :as => :last_message
  
  def messages
    booking_ids = Booking.created.for_user(current_user)
    messages = apply_scopes(BookingMessage.for_bookings( booking_ids))
    render :json => messages_to_json(messages)
  end
  
  protected    
  def collection
      @booking ||= end_of_association_chain.created.for_user(current_user)
  end
  
  # TODO: Move to model
  def messages_to_json(messages)
    messages.map{|msg|{
      "user_fb_id" => msg.user_fb_id,
       "message_class" => msg.html_class,
       "sent_at" => msg.created_at.to_formatted_s(:short), 
       "message" => msg.message,
       "id" => msg.id,
       "url" => booking_messages_path(msg.booking),
       "booking_id" => msg.booking_id
    }}.to_json
  end
end
