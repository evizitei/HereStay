class DealsController < ApplicationController
  layout 'application'
    
  inherit_resources
  actions :all, :except => [:destroy]
  before_filter :login_required, :except => %w(index show)
  before_filter :access_denied, :only => %w(edit update destroy)
  before_filter :format_money_params, :only => %w(create update)
  
  has_scope :active,  :only => :index, :default => 'true', :if => proc{|c| c.params[:upcoming].blank?  && c.params[:expired].blank?}
  
  def make
    if resource.make_with_user(current_user)
      flash[:notice] = 'Your deal was accepted'
    end
    redirect_to resource_url
  end
  
  def search
    result = RentalUnit.advanced_search_ids(params, current_user)
    @lots = Deal.active.with_rental_unit_ids(result).paginate(:page => params[:page], :per_page => 10)
    render 'index'
  end
  
  protected
    def collection
      @deals ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 10)
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
    
    def format_money_params
      if params[:deal] && params[:deal][:amount]
        params[:deal][:amount] = params[:deal][:amount].to_money
      end
    end
end
