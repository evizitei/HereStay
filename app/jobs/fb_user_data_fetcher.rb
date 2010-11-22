class FbUserDataFetcher
  def initialize(id)
    @user_id = id
  end

  def perform
    User.find(@user_id).capture_fb_profile_data!
  end
end