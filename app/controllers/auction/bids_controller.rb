class Auction::BidsController < Auction::BaseController
  inherit_resources
  belongs_to :lot
  before_filter :login_required
  before_filter :format_money_params, :only => :create
  helper_method :parent
  
  def create
    create!(:notice => 'Your bid is accepted', :location => parent_url(parent)) do |success, failure|
    
      failure.html do
        # replace resource variable to allow to correct render template auction/lots/show
        @replace_resource = parent
        render :template => 'auction/lots/show'
      end
    end
  end
  
  def win
    raise 'Error 403. Access denied.' unless parent.belongs_to?(current_user)
    resource.win!
    flash[:notice] = 'The bid marked as winning.'
    redirect_to parent_url
  end
  
  protected
    def resource
      @replace_resource || super
    end
    
    def create_resource(object)
      object.user = current_user
      object.save
    end
    
    def collection
      @collection = end_of_association_chain.by_cents
    end
end
