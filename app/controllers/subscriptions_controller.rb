class SubscriptionsController < ApplicationController
  layout 'application'
  before_filter :oauth_obj
  before_filter :login_required
  respond_to :html
  
  def new
    @subscription = Subscription.new()
    @subscription.user = current_user
  end
  
  def show    
    @billing_info = Recurly::BillingInfo.find(Recurly::Account.find(current_user.id).account_code)
  end
  
  def edit
    @subscription = current_user.subscription
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])
    @subscription.user = current_user
    @subscription.ip_address = request.remote_ip

    if @subscription.valid? && @subscription.save
      flash[:notice] = "Your was subscriped successfully."
    end
    respond_with(@subscription, :location => account_path)
  end
  
  def update
    @subscription = Subscription.new(params[:subscription])
    @subscription.user = current_user
    @subscription.ip_address = request.remote_ip

    if @subscription.valid? && @subscription.save
      flash[:notice] = "Your subscription was updated."
    end
    respond_with(@subscription, :location => account_path)
  end
  
  def destroy
    current_user.subscription.destroy
    flash[:notice] = "Your subscription was canceled."
    respond_with(:location => account_path)
  end
  
  def change_plan
    @subscription = current_user.subscription
  end
end
