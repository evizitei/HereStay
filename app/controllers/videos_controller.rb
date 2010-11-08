class VideosController < ApplicationController
  before_filter :oauth_obj
  before_filter :login_required
  before_filter :get_rental_unit
  
  def show
    unless @rental_unit.has_video?
      @upload_token = @rental_unit.upload_token
    end
  end
  
  def save
    @rental_unit.update_attributes!(:video_id=>params[:id],:video_status=>params[:status],:video_code=>params[:code])
    flash[:notice] = 'Video was uploaded successfully.'
    redirect_to rental_unit_video_path(@rental_unit)
  end
  
  def destroy
    YoutubeProxy.new.delete_video(@rental_unit.video_id, YoutubeToken.current)
    @rental_unit.update_attributes!(:video_id=>nil,:video_status=>nil,:video_code=>nil)
    flash[:notice] = 'Video was deleted successfully.'
    redirect_to manage_rental_units_path(@rental_unit)
  end

  protected
   def get_rental_unit
      @rental_unit = @user.rental_units.find(params[:rental_unit_id])
   end
end
