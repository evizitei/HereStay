class BookingsController < ApplicationController
  before_filter :oauth_obj
  before_filter :get_rental_unit, :only => %w(index new create)
  before_filter :get_booking, :only => %w(show confirm exec_confirm wall_post renter_confirm edit update)
  
  rescue_from ActiveRecord::RecordNotSaved, :with => :confirmation_error
  respond_to :html
  def index
    @bookings = @rental_unit.bookings
  end
  
  def show
  end
  
  def new
    @booking = @rental_unit.bookings.build
  end
  
  def create
    @booking = @rental_unit.bookings.build(params[:booking])
    @booking.complete
    respond_to do |format|
      if @booking.save
        flash[:notice] = 'Booking was created successfully.'
        format.html{redirect_to rental_unit_bookings_url(@booking.rental_unit)}
      else
        format.html{render 'new'}
      end
    end
  end
  
  def edit
     @rental_unit = @booking.rental_unit
  end
  
  def update
    if @booking.update_attributes(params[:booking])
      flash[:notice] = 'Booking was updated successfully.'
    end
    respond_with(@booking, :location => rental_unit_bookings_url(@booking.rental_unit))
  end
  
  # TODO: move to message controller
  def discuss
    if params[:id]
      get_booking
    elsif params[:rental_unit_id]
      # find existing uncomplete booking or create new for user @user
      @booking = get_rental_unit.find_uncompleted_booking_for_user_or_create(@user)
    end
  end
  
  def mobile_discuss
    get_booking
    @user = User.find(params[:user_id])
    render :layout=>nil
  end
  
  def confirm
  end
  
  def exec_confirm
    respond_to do |format|
      if  @booking.update_attributes_and_confirm(params[:booking])
        flash[:notice] = 'Booking was confirmed.'
        format.html{redirect_to rental_unit_bookings_url(@booking.rental_unit)}
      else
        format.html{render 'confirm'}
      end
    end
  end
  
  def wall_post
    @booking.wall_post_by_user!(@user)
    redirect_to @booking
  end
  
  def renter_confirm
    @booking.confirm_by_renter!
    render :action=>:show
  end
  
  private
    def get_rental_unit
      @rental_unit = RentalUnit.find(params[:rental_unit_id])
    end
    
    def get_booking
      @booking = Booking.find(params[:id])
    end
    
    # Handle errors occure in after_save callback (post to wall, post Vrbo reservation)
    def confirmation_error
      @booking.errors.add_to_base('Can\'t confirm booking.')
      source_page = self.action_name == 'exec_confirm' ? 'confirm' : 'new'
      render source_page
    end
end
