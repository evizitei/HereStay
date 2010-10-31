class AccountController < ApplicationController
  def show
    @my_bookings = Booking.where(:renter_fb_id=>@user.fb_user_id)
    @bookings = Booking.joins(:rental_unit).where("rental_units.user_id = #{@user.id}")
    @rewards = @user.rewards
  end
   
  def edit
  end
  
  def update
    @user.update_attributes!(params[:user])
    redirect_to manage_rental_units_url
  end
end