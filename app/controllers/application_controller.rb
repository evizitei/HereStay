class ApplicationController < ActionController::Base
  #protect_from_forgery
  layout 'canvas'
  helper_method :fb_app_name
  
  before_filter :redirect_from_params

protected
  
  def oauth_obj
    oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s)
    @user = User.for(oauth.get_user_info_from_cookie(cookies))
  end
  
  def fb_app_name
    Facebook::APP_NAME.to_s
  end
  
  def login_required
    unless @user
      render "shared/login_required", :layout => 'canvas'
      return false
    end
  end
  
  # redirect to specified application page.
  def redirect_from_params
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    end
  end
end
