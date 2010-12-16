class PhotosController < ApplicationController
  before_filter :oauth_obj
  
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
    if @photo.save
      responds_to_parent do |page|
        page << "$('#preview_image_id').val('#{@photo.id}')"; 
        page << "$('#preview_img').attr('src', '#{@photo.picture.url(:thumb)}')"
      end
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
