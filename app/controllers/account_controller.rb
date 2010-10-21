class AccountController < ApplicationController
  layout "canvas"
  
  def edit
  end
  
  def update
    @user.update_attributes!(params[:user])
    redirect_to manage_my_rental_units_url
  end
end