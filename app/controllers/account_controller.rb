class AccountController < ApplicationController
  layout "canvas"
  
  def show
    @my_bookings = Booking.where(:renter_fb_id=>@user.fb_user_id)
    @rewards = @user.rewards
  end
   
  def edit
  end
  
  def update
    @user.update_attributes!(params[:user])
    redirect_to manage_my_rental_units_url
  end
end