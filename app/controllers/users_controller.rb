class UsersController < ApplicationController
  def create
    user = User.find_or_create_by_fb_user_id(params[:user_id])
    user.update_attributes!(:session_expires_at=>Time.at(params[:expires].to_i),:authorize_signature=>params[:oauth_token])
    render :text=>""
  end
end