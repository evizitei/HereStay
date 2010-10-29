class MyRentalUnitsController < ApplicationController
  layout "canvas"
  before_filter :login_required, :except => %w(index show share photos_for owned_by)
  
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
    @rental_units = @user.rental_units
  end
  
  def new
    @rental_unit = RentalUnit.new()
  end
  
  def edit
    @rental_unit = @user.rental_units.find(params[:id])
  end
  
  def create
    @rental_unit = @user.rental_units.build(params[:rental_unit])
    @rental_unit.save!
    redirect_to manage_my_rental_units_url
  end
  
  def update
    @rental_unit = @user.rental_units.find(params[:id])
    @rental_unit.update_attributes!(params[:rental_unit])
    redirect_to manage_my_rental_units_url
  end
  
  def show
    @rental_unit = RentalUnit.find(params[:id])
    @og_meta = {:title=>@rental_unit.name,
                :type=>"hotel",
                :image=>@rental_unit.picture.url(:thumb),
                :url=>my_rental_unit_url(@rental_unit),
                :site_name=>"HereStay",
                :app_id=>Facebook::APP_ID}
  end
  
  def destroy
    @rental_unit = @user.rental_units.find(params[:id])
    @rental_unit.destroy
    redirect_to manage_my_rental_units_url
  end
  
  def load_from_vrbo
    rental_unit = @user.rental_units.find(params[:id])
    rental_unit.load_from_vrbo!
    flash[:notice] = "Full listing loaded from Vrbo successfully. Photos will be imported in some minutes."
    redirect_to edit_my_rental_unit_url(rental_unit)
  end
  
  def import
    RentalUnit.import_from_vrbo!(@user)
    flash[:notice] = "Listings were imported from Vrbo successfully."
    redirect_to manage_my_rental_units_url
  end
  
  def share
    @rental_unit = RentalUnit.find(params[:id])
    unless @rental_unit.user == @user
      redirect_to "http://apps.facebook.com/#{fb_app_name}"
    end
  end
  
  def photos_for
    @rental_unit = RentalUnit.find(params[:id])
    @photos = @rental_unit.photos
    @photo = @rental_unit.photos.new
  end
  
  def delete_photo
    rental_unit = @user.rental_units.find(params[:id])
    rental_unit.photos.find(params[:photo_id]).destroy
    flash[:notice] = "Photo was deleted successfully"
    redirect_to  photos_for_my_rental_unit_url(rental_unit)
  end
  
  def new_photo
    rental_unit =  @user.rental_units.find(params[:id])
    photo = rental_unit.photos.create!(params[:photo])
    flash[:notice] = "Photo was added successfully"
    redirect_to photos_for_my_rental_unit_path(rental_unit)
  end
  
  def owned_by
    @user = User.find params[:user_id]
    @rental_units = @user.rental_units.paginate(:page => params[:page], :per_page => 1)
  end
  
  def upload_video_for
    @rental_unit = RentalUnit.find(params[:id])
    @upload_token = @rental_unit.upload_token  
  end
  
  def video_uploaded
    rental_unit = RentalUnit.find(params[:unit_id])
    rental_unit.update_attributes!(:video_id=>params[:id],:video_status=>params[:status],:video_code=>params[:code])
    redirect_to my_rental_unit_path(rental_unit.id)
  end
end
