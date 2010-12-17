class Auction::LotsController < Auction::BaseController
  inherit_resources
  actions :all, :except => [:destroy]
  before_filter :login_required, :except => %w(index show)
  before_filter :access_denied, :only => %w(edit update finish destroy)
  before_filter :format_money_params, :only => %w(create update)
  
  has_scope :closest, :default => 'true', :only => [:index]
  has_scope :upcoming, :only => [:index]
  has_scope :expired, :only => [:index]
  
  
  def finish
    resource.finish!
    redirect_to resource_url
  end
  
  protected
    def collection
      @lots ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 10)
    end
    
    def access_denied
      raise 'Error 403. Access denied.' unless resource.belongs_to?(current_user)
    end
    
    def create_resource(object)
      object.creator = current_user
      object.save
    end
    
    def update_resource(object, attributes)
      object.update_attributes(attributes.merge(:creator => current_user))
    end
end
