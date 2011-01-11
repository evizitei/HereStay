class VideosController < ApplicationController
  before_filter :oauth_obj
  before_filter :login_required
  before_filter :get_rental_unit
  layout 'application'
  def show
    unless @rental_unit.has_video?
      @upload_info = YoutubeProxy.new.upload_token(
        {:title => @rental_unit.name, :description => @rental_unit.youtube_description},
        save_rental_unit_video_url(@rental_unit)
      )
    end
  end
  
  def save
    @rental_unit.update_attributes!(:video_id=>params[:id],:video_status=>params[:status],:video_code=>params[:code])
    flash[:notice] = 'Video was uploaded successfully.'
    redirect_to rental_unit_video_path(@rental_unit)
  end
  
  def destroy
    @rental_unit.delete_youtube_video
    flash[:notice] = 'Video was deleted successfully.'
    redirect_to manage_rental_units_path(@rental_unit)
  end
  
  def generate
    @rental_unit.generate_video_and_upload
    flash[:notice] = 'Video was created.'
    redirect_to rental_unit_video_url(@rental_unit)
  end

  protected
   def get_rental_unit
      @rental_unit = current_user.rental_units.find(params[:rental_unit_id])
   end
end
