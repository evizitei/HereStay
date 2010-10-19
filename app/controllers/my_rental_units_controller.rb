class MyRentalUnitsController < ApplicationController
  layout "canvas"
  
  def index
    @app_page = (params[:profile_id].to_s == "123982284313527")
    if @app_page
      offset = rand(RentalUnit.order("id DESC").limit(1).select("id").first.id - 5) rescue 0
      @rental_units = RentalUnit.order("id ASC").limit(5).where("id >= #{offset}")
    else
      @rental_units = RentalUnit.find_all_by_fb_user_id(params[:profile_id])
      if @rental_units.size == 0
        @app_page = true
        offset = rand(RentalUnit.order("id DESC").limit(1).select("id").first.id - 5) rescue 0
        @rental_units = RentalUnit.order("id ASC").limit(5).where("id >= #{offset}")
      end
    end
  end
  
  def manage
    @rental_units = RentalUnit.find_all_by_fb_user_id(params[:user_id])
  end
  
  def new
    @rental_unit = RentalUnit.new()
  end
  
  def edit
    @rental_unit = RentalUnit.find(params[:id])
  end
  
  def save
    @rental_unit = (params[:rental_unit][:id].blank? ? 
                      RentalUnit.new(:fb_user_id=>params[:user_id]) : 
                      RentalUnit.find(params[:rental_unit][:id]))
    @rental_unit.update_attributes!(params[:rental_unit])
    render :text => fb_redirect_to("http://apps.facebook.com/#{fb_app_name}/my_rental_units/share?id=#{@rental_unit.id}")
  end
  
  def show
    @rental_unit = RentalUnit.find(params[:id])
  end
  
  def delete
    @rental_unit = RentalUnit.find(params[:id])
    @rental_unit.destroy
    redirect_to :action=>:manage
  end
  
  def share
    @rental_unit = RentalUnit.find(params[:id])
    if params[:user_id].to_s != @rental_unit.fb_user_id.to_s
      redirect_to "http://apps.facebook.com/#{fb_app_name}"
    end
  end
  
  def photos
    @rental_unit = RentalUnit.find(params[:id])
    @photos = @rental_unit.photos
    @photo = @rental_unit.photos.new
  end
  
  def delete_photo
    photo = Photo.find(params[:id])
    photo.destroy
    @rental_unit = RentalUnit.find(photo.rental_unit_id)
    @photos = @rental_unit.photos
    @photo = @rental_unit.photos.new
    render :action=>:photos
  end
  
  def new_photo
    photo = Photo.create!(params[:photo])
    redirect_to "http://apps.facebook.com/#{fb_app_name}/my_rental_unit_photos?id=#{photo.rental_unit_id}"
  end
  
  def owned_by
    @owner_id = params[:owner_id]
    @rental_units = RentalUnit.find_all_by_fb_user_id(@owner_id)
  end
  
  def upload_video
    @rental_unit = RentalUnit.find(params[:id])
    @upload_token = @rental_unit.upload_token  
  end
  
  def video_uploaded
    rental_unit = RentalUnit.find(params[:unit_id])
    rental_unit.update_attributes!(:video_id=>params[:id],:video_status=>params[:status],:video_code=>params[:code])
    redirect_to rental_unit.fb_url
  end
end
