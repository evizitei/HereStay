class Admin::FundsController < Admin::BaseController
  inherit_resources
  
  protected
    def collection
      @funds ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 50)
    end
end
