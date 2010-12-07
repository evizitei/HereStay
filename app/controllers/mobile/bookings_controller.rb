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
  def begin_of_association_chain
    current_user
  end
  
  def update_resource(object, attributes)
    object.update_attributes_and_reserve(attributes)
  end
end