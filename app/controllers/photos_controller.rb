class PhotosController < InheritedResources::Base
  belongs_to :rental_unit
  layout 'canvas'
  helper_method :parent
  helper :all
  
  before_filter :login_required
  
  def destroy
    destroy! :notice => "Photo was deleted successfully.", :location => collection_url
  end

  def create
    create! :notice => "Photo was added successfully.", :location => collection_url
  end
  
  protected
    def begin_of_association_chain
      @user
    end
end
