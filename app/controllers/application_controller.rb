class ApplicationController < ActionController::Base
  #protect_from_forgery
  layout 'application'
  helper_method :fb_app_name
  
  before_filter :debug_params
  before_filter :update_user
  begore_filter :oauth_obj
  
protected
  def debug_params
    @params = params
    @cookies = cookies
  end
  
  def oauth_obj
    @oauth = Koala::Facebook::OAuth.new(FB_ID, FB_SECRET)
  end
  
  def fb_app_name
    Facebook::APP_NAME.to_s
  end
  
  def fb_redirect_to(url)
    "<fb:redirect url=\"#{url_for(url)}\" />"
  end
  
  def update_user
    if params[:user_id]
      user = User.find_by_fb_user_id(params[:user_id])
      if user
        auth_token = params[:oauth_token]
        if auth_token
          if user.authorize_signature != auth_token
            user.update_attributes!(:authorize_signature=>auth_token,:session_expires_at=>Time.at(params[:expires]))
          end
        
          if user.email.nil?
            Delayed::Job.enqueue(FbEmailFetcher.new(user.fb_user_id))
          end
        else
          puts "NO AUTH TOKEN!!!"
        end
      else
        puts "NO USER!!!"
      end
    end
  end
end
