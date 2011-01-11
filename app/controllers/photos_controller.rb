class PhotosController < ApplicationController
  layout 'application'
  # before_filter :oauth_obj
  
  inherit_resources

  belongs_to :rental_unit, :optional => true
  helper_method :parent
  
  before_filter :login_required
  
  def destroy
    destroy! :notice => "Photo was deleted successfully.", :location => collection_url
  end

  def create
    create! :notice => "Photo was added successfully.", :location => collection_url
  end
  
  def update
    update! :notice => "Photo was marked as primary.",:location => collection_url
  end
  
  def ajaxupload
    @photo = Photo.new(params[:photo])
    @photo.primary = false
    if @photo.save
      responds_to_parent do |page|
        page << "$('#picture-fields').prepend(#{render(:partial => 'photo', :object => @photo, :locals => {:primary => false}).dump})"
        page << "redrawPhotos();$('.ajax_photo_loader').hide();"
      end
    end
  end
  
  def ajaxupload_remote
    if !params[:remote_photo].blank? && @photo = Photo.create(:image_url => params[:remote_photo])
      render :partial => 'photo', :object => @photo, :locals => {:primary => true}
    end
  end
  
  protected
    def begin_of_association_chain
      current_user
    end
    
    def update_resource(obj, attributes)
      obj.primary!
    end
end
