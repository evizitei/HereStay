class SubscriptionsController < ApplicationController
  before_filter :oauth_obj
  before_filter :login_required
  respond_to :html
  
  def edit
    @subscription = Subscription.new({:plan => current_user.subscription_plan})
    @subscription.user = current_user
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
    @subscription = Subscription.new({:user => current_user})
    @subscription.destroy
    flash[:notice] = "Your subscription was canceled."
    respond_with(:location => account_path)
  end
end
