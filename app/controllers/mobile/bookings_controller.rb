class Mobile::BookingsController < InheritedResources::Base
  layout 'mobile'
  before_filter :login_required
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  respond_to :html
  actions :show, :update, :edit
  
  def update
    update!(:notice => 'Booking was confirmed.')    
  end
  
  protected
  def resource
    @booking ||= current_user.bookings.find(params[:id])
  end
  
  def update_resource(object, attributes)
    object.save
  end
end