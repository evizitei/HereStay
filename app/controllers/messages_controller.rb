class MessagesController < InheritedResources::Base
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
  respond_to :html
  actions :create
  belongs_to :booking
  
  before_filter :login_required
  
  def create
    create!(:location => discuss_booking_path(parent), :notice => "Message created.")
  end
  
  protected
  def create_resource(object)
    object.user_fb_id = @user.fb_user_id
    object.save
  end
end
