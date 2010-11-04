require 'twitter_wrapper'
class Connectors::TwitterController < ApplicationController
  before_filter :login_required
  before_filter :twitter_wrapper
  
  def show
    @wrapper.twitter.home_timeline.inspect
  end
  
  def new
    begin
      session[:rtoken], session[:rsecret] = @wrapper.request_token.token, @wrapper.request_token.secret
      redirect_to @wrapper.authorize_url
    rescue
     flash[:alert] = 'Error while connecting with Twitter. Please try again.'
     redirect_to edit_account_path
    end
  end
  
  def callback
    begin
      result = @wrapper.get_access_token(session[:rtoken], session[:rsecret], params[:oauth_verifier])
      flash[:notice] = "Successfully signed in with Twitter."
    rescue
      flash[:alert] = 'You were not authorized by Twitter!'
    end
    redirect_to edit_account_path
  end
  
  private
    def twitter_wrapper
      @wrapper = TwitterWrapper.new(@user)
    end
end
