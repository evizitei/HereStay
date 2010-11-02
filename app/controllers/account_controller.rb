class AccountController < ApplicationController
  respond_to :html
  
  def show
    @my_bookings = Booking.where(:renter_fb_id=>@user.fb_user_id)
    @bookings = @user.bookings
    @rewards = @user.rewards
  end
   
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your account was updated."
    end
    respond_with(@user, :location => account_url)
  end
end