class Renter::BookingsController < ApplicationController
  inherit_resources
  layout 'application'
  
  before_filter :login_required
  
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  respond_to :html
  actions :index, :show, :confirm
  
  has_scope :reserved, :only =>[:index], :type => :boolean, :default => true
  has_scope :not_confirmed, :type => :boolean, :default => true, :only =>[:index] do |controller, scope, value|
    controller.params[:confirmed].blank? ? scope.not_confirmed : scope
  end
  has_scope :confirmed, :only =>[:index]  
  
  def confirm
    flash[:notice] = 'This booking is complete!' if resource.confirm_by_renter!
    render :action => :show
  end
  
  def wall_post
    @booking.wall_post_by_user!(current_user)
    redirect_to @booking
  end
  
  private  
  def collection
    @booking ||= end_of_association_chain.active.for_renter(current_user)
  end
end
