class FbFriendsFetcher
  def initialize(id)
    @user_id = id
  end
  
  def perform
    User.find(@user_id).get_fb_friend_ids!
  end
end