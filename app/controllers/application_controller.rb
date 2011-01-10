class ApplicationController < ActionController::Base
  #protect_from_forgery
  layout 'canvas'
  helper_method :fb_app_name, :current_user, :logged_in?
  
  before_filter :redirect_from_params
  before_filter :oauth_obj
  before_filter :load_info_for_sidebar
  after_filter :set_headers
protected
  
  def oauth_obj
    @current_user = User.for(FacebookProxy.get_user_info_from_cookie(cookies))
  end
  
  def fb_app_name
    Facebook::APP_NAME.to_s
  end
  
  def load_info_for_sidebar
    @online_rental_units = User.online.map(&:rental_units).flatten
    @my_network_properties = current_user.rental_units_of_friends if current_user
  end
  
  def login_required
    unless current_user
      render "shared/login_required"
      return false
    end
  end
  
  def current_user
    @current_user
  end
  
  def logged_in?
    current_user.present?
  end
  
  def subscription_required
    login_required
    unless current_user.subscribed?
      flash[:alert] = "Please, select the subscription plane to continue."
      redirect_to edit_subscription_path
      return false
    end
  end
  
  # redirect to specified application page.
  def redirect_from_params
    if params[:redirect_to]
      redirect_to params[:redirect_to]
    end
  end
  
  
  def user_puls
    current_user.pulse! if current_user
  end
  
  def set_headers
    response.headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
  end
end
