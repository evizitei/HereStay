class AccountController < ApplicationController
  layout 'application'
  
  before_filter :oauth_obj
  before_filter :login_required
  respond_to :html
  
  def show
    # @my_bookings = Booking.active.where(:renter_fb_id => current_user.fb_user_id)
    # render 'my_history'
  end
    
  def my_history
    @my_bookings = Booking.active.where("renter_fb_id = ? OR owner_fb_id = ?", current_user.fb_user_id, current_user.fb_user_id)
  end
  
  def my_place
    @bookings = current_user.bookings.active
  end
  
  def my_rewards
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