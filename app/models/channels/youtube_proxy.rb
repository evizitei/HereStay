class YoutubeProxy
  def initialize
    @client = YouTubeIt::Client.new(:username => YOUTUBE_USERNAME, :password => YOUTUBE_PASSWORD, :dev_key => YOUTUBE_API_KEY)
  end
  
  def client
    @client
  end
  
  def delete_video(video_id)
    @client.video_delete(video_id)
  end
  
  def upload_video(video, options = {})
    options.reverse_merge! default_options
    @client.video_upload(File.open(video), options)
  end
  
  def upload_token(params, nexturl)
    params.reverse_merge! default_options
    client.upload_token(params, nexturl)
  end
  
  private
  def default_options
   { :title => "HereStay video", :description => "HereStay Video. Visit http://apps.facebook.com/here_stay",
     :category => 'Travel', :keywords => %w[vacation house rental]
   }
  end
end