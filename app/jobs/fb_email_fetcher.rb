require 'httparty'

class FbEmailFetcher
  def initialize(id)
    @fb_user_id = id
  end
  
  def perform
    user = User.find_by_fb_user_id(@fb_user_id)
    graph = HTTParty.get("https://graph.facebook.com/me?access_token=#{CGI::escape(user.authorize_signature)}").parsed_response
    user.update_attributes!(:email=>graph["email"])
  end
end