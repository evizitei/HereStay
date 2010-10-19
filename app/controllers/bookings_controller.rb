require 'httparty'

class BookingsController < ApplicationController
  layout "canvas"
  
  def index
    @rental_unit = RentalUnit.find(params[:id])
    @bookings = @rental_unit.bookings
  end
  
  def new
    @rental_unit = RentalUnit.find(params[:id])
    @booking = @rental_unit.bookings.build
  end
  
  def create
    @rental_unit = RentalUnit.find(params[:id])
    booking = @rental_unit.bookings.create!(params[:booking])
    booking.status = "COMPLETE"
    booking.renter_name = params[:renter_name] if params[:renter_name]
    booking.renter_fb_id = params[:renter_fb_id] if params[:renter_fb_id]
    booking.save!
    redirect_to :action=>:index,:id=>@rental_unit.id
  end
  
  def discuss
    @user_id = params[:user_id]
    if params[:booking_id]
      @booking = Booking.find(params[:booking_id])
      @rental_unit = @booking.rental_unit
    elsif params[:id]
      @rental_unit = RentalUnit.find(params[:id])
      @booking = @rental_unit.bookings.find_by_renter_fb_id_and_owner_fb_id(params[:user_id],@rental_unit.fb_user_id)
      if @booking.nil? or @booking.status == "COMPLETE"
        @booking = @rental_unit.bookings.create!(:renter_fb_id=>params[:user_id],:owner_fb_id=>@rental_unit.fb_user_id)
      end
    end
    @messages = @booking.booking_messages.order("created_at ASC")
  end
  
  def create_message
    @booking = Booking.find(params[:booking_message][:booking_id])
    @booking.booking_messages.create!(params[:booking_message])
    redirect_to :action=>:discuss,:booking_id=>@booking.id
  end
  
  def confirm
    @booking = Booking.find(params[:booking_id])
    @rental_unit = @booking.rental_unit
  end
  
  def exec_confirm
    @booking = Booking.find(params[:booking_id])
    @booking.update_attributes(params[:booking])
    @booking.confirm!
    redirect_to :action=>:index,:id=>@booking.rental_unit.id 
  end
  
  def details
    @booking = Booking.find(params[:booking_id])
    @rental_unit = @booking.rental_unit
  end
  
  def wall_post
    user = User.find_by_fb_user_id(params[:user_id])
    booking = Booking.find(params[:booking_id])
    HTTParty.post("https://graph.facebook.com/me/feed",{:body=>{:access_token=>user.authorize_signature,:message=>"I'm going on a trip, staying at a place I found on HereStay!",:picture=>booking.rental_unit.picture.url(:thumb),:link=>booking.rental_unit.fb_url,:name=>"Check it out!",:caption=>"See for yourself",:description=>"Stay at a friends place by finding it on HereStay"}})
    Discount.create!(:user_id=>user.id,:booking_id=>booking.id)
    redirect_to :action=>:details,:booking_id=>booking.id                                                                
  end
end
