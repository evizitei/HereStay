class BookingsController < ApplicationController
  inherit_resources
  
  before_filter :login_required
  
  defaults :resource_class => Booking, :collection_name => 'bookings', :instance_name => 'booking'
  respond_to :html
  belongs_to :rental_unit
  actions :index, :new, :create, :edit, :update, :show, :confirm, :exec_confirm
  helper_method :parent
  
  has_scope :not_confirmed, :type => :boolean, :default => true, :only =>[:index] do |controller, scope, value|
    controller.params[:confirmed].blank? ? scope.not_confirmed : scope
  end
  has_scope :confirmed, :only =>[:index]
  
  
  rescue_from ActiveRecord::RecordNotSaved, :with => :confirmation_error
  
  def create
    create!(:location => collection_url, :notice => 'Booking was created successfully.')
  end
  
  def update
    update!(:location => collection_url, :notice => 'Booking was created successfully.')
  end
 
  # TODO: move to message controller
  def discuss
    @rental_unit =  RentalUnit.find(params[:rental_unit_id])
    @booking = @rental_unit.find_uncompleted_booking_for_user_or_create(current_user)
    redirect_to [@booking, :messages]
  end

  def confirm
  end
  
  def exec_confirm
    respond_to do |format|
      if  resource.update_attributes_and_reserve(params[:booking])
        flash[:notice] = 'Booking was confirmed.'
        format.html{redirect_to rental_unit_bookings_url(@booking.rental_unit)}
      else
        format.html{render 'confirm'}
      end
    end
  end
  
  def wall_post
    @booking.wall_post_by_user!(current_user)
    redirect_to @booking
  end
  
  def renter_confirm
    @booking.confirm_by_renter!
    render :action=>:show
  end
  
  def cancel
    @booking = Booking.active.find params[:id]
    flash[:notice] = "Booking was canceled!" if @booking.cancel_by(current_user)
    redirect_to :back
  end
  
  private
  def parent
    @rental_unit ||= current_user.rental_units.find(params[:rental_unit_id])
  end
  
  def begin_of_association_chain
    parent
  end
  
  def create_resource(object)
    object.reserve
    object.save
  end
  
  def collection
      @booking ||= end_of_association_chain.active
  end
    
    # Handle errors occure in after_save callback (post to wall, post Vrbo reservation)
    def confirmation_error
      @booking.errors.add_to_base('Can\'t confirm booking.')
      source_page = self.action_name == 'exec_confirm' ? 'confirm' : 'new'
      render source_page
    end
end
