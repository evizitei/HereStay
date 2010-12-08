class AccountController < ApplicationController
  before_filter :oauth_obj
  before_filter :login_required
  respond_to :html
  
  def show
    @my_bookings = Booking.active.where(:renter_fb_id => current_user.fb_user_id)
    @bookings = current_user.bookings.active
    @rewards = current_user.rewards
  end
   
  def edit
  end
  
  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = "Your account was updated."
    end
    respond_with(current_user, :location => account_url)
  end
end