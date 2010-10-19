class AccountController < ApplicationController
  layout "canvas"
  
  def edit
    @user = User.find_by_fb_user_id(params[:user_id])
  end
  
  def save
    @user = User.find_by_fb_user_id(params[:user_id])
    @user.update_attributes!(params[:user])
    redirect_to :controller=>:my_rental_units,:action=>:manage
  end
end