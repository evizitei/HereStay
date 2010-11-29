class ApplicationController < ActionController::Base
  #protect_from_forgery
  layout 'canvas'
  helper_method :fb_app_name, :current_user, :logged_in?
  
  before_filter :redirect_from_params

protected
  
  def oauth_obj
    @current_user = User.for(FacebookProxy.get_user_info_from_cookie(cookies))
  end
  
  def fb_app_name
    Facebook::APP_NAME.to_s
  end
  
  def login_required
    unless current_user
      render "shared/login_required", :layout => 'canvas'
      return false
    end
  end
  
  def current_user
    @current_user
  end
  
  def logged_in?
    current_user.present?
  end
  
  # redirect to specified application page.
  def redirect_from_params
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    end
  end
end
