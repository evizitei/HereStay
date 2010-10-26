class BookingsController < ApplicationController
  layout "canvas"
  before_filter :get_rental_unit, :only => %w(index new create)
  before_filter :get_booking, :only => %w(show confirm exec_confirm wall_post)
  
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
    @booking.save!
    flash[:notice] = 'Booking created successfully.'
    redirect_to my_rental_unit_bookings_url(@booking.rental_unit)
  end
  
  # TODO: move to message controller
  def discuss
    if params[:id]
      get_booking
    elsif params[:my_rental_unit_id]
      # find existing uncomplete booking or create new for user @user
      @booking = get_rental_unit.find_uncompleted_booking_for_user_or_create(@user)
    end
  end
  
  def confirm
  end
  
  def exec_confirm
    @booking.update_attributes_and_confirm!(params[:booking])
    redirect_to my_rental_unit_bookings_url(@booking.rental_unit)
  end
  
  def wall_post
    @booking.wall_post_by_user!(@user)
    redirect_to @booking
  end
  
  private
    def get_rental_unit
      @rental_unit = RentalUnit.find(params[:rental_unit_id]||params[:my_rental_unit_id])
    end
    
    def get_booking
      @booking = Booking.find(params[:id])
    end
end
