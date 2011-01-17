class InquiriesController < ApplicationController
  inherit_resources
  layout 'application'
  before_filter :login_required
  after_filter :user_puls
  
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  actions :index, :create, :terminate
  respond_to :html, :only => [:index, :new]
  belongs_to :rental_unit, :optional => true
  respond_to :json
  
  has_scope :created, :type => :boolean, :default => true
  has_scope :not_terminated, :type => :boolean, :default => true
  
  def messages
    booking_ids = apply_scopes(Booking).for_user(current_user)
    messages = BookingMessage.last_messages(params[:last_message]).for_bookings( booking_ids)
    render :json => messages_to_json(messages)
  end
  
  def new
    @rental_unit =  RentalUnit.find(params[:rental_unit_id])
    @booking = @rental_unit.find_uncompleted_booking_for_user_or_create(current_user)
    redirect_to rental_unit_inquiries_url @rental_unit
  end
  
  def terminate
    resource.terminate_chat!
    respond_to do |format|
      format.html{redirect_to :back}
      format.js{render :text => 'ok'}
    end 
  end
  
  protected    
  def collection
      @bookings ||= end_of_association_chain.for_user(current_user)
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
