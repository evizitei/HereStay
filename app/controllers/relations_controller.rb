class RelationsController < ApplicationController
  before_filter :oauth_obj
  before_filter :login_required
  
  def show
    @owner = User.find(params[:id])
    if current_user.friend_of?(@owner)
      @friend = true
    elsif current_user.mutual_friends_with(@owner).present?
      @mutual_friend = current_user.mutual_friends_with(@owner).first
    else
      @not_friend = true
    end
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
