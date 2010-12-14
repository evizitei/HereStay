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
  
  protected
    def resource
      @replace_resource || super
    end
    
    def create_resource(object)
      object.user = current_user
      object.save
    end
end
