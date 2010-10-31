class PhotosController < ApplicationController
  inherit_resources

  belongs_to :rental_unit
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
  
  protected
    def begin_of_association_chain
      @user
    end
    
    def update_resource(obj, attributes)
      obj.primary!
    end
end
