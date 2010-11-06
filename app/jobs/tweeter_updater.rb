class TweeterUpdater
  def initialize(user, message, url)
    @message = message
    @user = user
    @url = url
  end

  def perform
    @user = User.find(@user) if @user.is_a?(Integer)
    TwitterWrapper.new(@user).post_with_url(@message, @url)
  end
end