class YoutubeToken < ActiveRecord::Base
  def self.current
    self.order("created_at DESC").first.value
  end
end
