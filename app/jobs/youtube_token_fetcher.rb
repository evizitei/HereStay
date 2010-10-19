class YoutubeTokenFetcher
  def perform
    token = YoutubeProxy.new.get_auth_token(YOUTUBE_USERNAME,YOUTUBE_PASSWORD)
    YoutubeToken.create!(:value=>token)
    Delayed::Job.enqueue(self, 0, 8.hours.from_now)
  end
end