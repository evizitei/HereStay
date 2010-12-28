class BookingsController < ApplicationController
  inherit_resources
  layout 'application'
  
  before_filter :login_required
  
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  respond_to :html
  belongs_to :rental_unit, :optional => true
  actions :index, :new, :create, :edit, :update, :show, :reserve, :exec_reserve
  helper_method :parent
  
  has_scope :reserved, :only =>[:index], :type => :boolean, :default => true
  has_scope :not_confirmed, :type => :boolean, :default => true, :only =>[:index] do |controller, scope, value|
    controller.params[:confirmed].blank? ? scope.not_confirmed : scope
  end
  has_scope :confirmed, :only =>[:index]  
  
  rescue_from ActiveRecord::RecordNotSaved, :with => :reservation_error
  
  def create
    create!(:location => rental_unit_bookings_url(parent), :notice => 'Booking was created successfully.')
  end
  
  def update
    update!(:location => rental_unit_bookings_url(parent), :notice => 'Booking was updated successfully.')
  end

  def reserve
  end
  
  def exec_reserve
    respond_to do |format|
      if  resource.update_attributes_and_reserve(params[:booking])
        flash[:notice] = 'Booking was reserved.'
        format.html{redirect_to rental_unit_bookings_url(@booking.rental_unit)}
      else
        format.html{render 'reserve'}
      end
    end
  end
  
  def wall_post
    @booking.wall_post_by_user!(current_user)
    redirect_to @booking
  end
  
  def cancel
    @booking = Booking.active.find params[:id]
    flash[:notice] = "Booking was canceled!" if @booking.cancel_by(current_user)
    redirect_to :back
  end
  
  private  
  def begin_of_association_chain
    current_user
  end
  
  def create_resource(object)
    object.reserve! if object.save
     
  end
  
  def collection
      @booking ||= end_of_association_chain.active
  end
    
    # Handle errors occure in after_save callback (post to wall, post Vrbo reservation)
    def reservation_error
      @booking.errors.add_to_base('Can\'t reserve booking.')
      source_page = self.action_name == 'exec_reserve' ? 'reserve' : 'new'
      render source_page
    end
end
