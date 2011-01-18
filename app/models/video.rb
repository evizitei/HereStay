class Video < ActiveRecord::Base
  belongs_to :rental_unit
  
  # status: pending - video creation created as background job,
  #   completed - video is uploaded to youtube server
  #   error
  
  before_destroy :clear_youtube_video
  
  def self.generate_for_rental_unit(rental_unit)
    video = rental_unit.create_video(:status => 'pending')
    video.delay.process!
    video
  end
  
  def process!
    rental_unit = self.rental_unit
    begin
      v = VideoCreator.new(rental_unit.photos.map{|m| m.picture.url(:video)})
      v.process!
      
      resp = YoutubeProxy.new.upload_video(v.path_to_file, {:title => rental_unit.name, :description => rental_unit.youtube_description})
      
      self.youtube_id = resp.video_id.gsub('http://gdata.youtube.com/feeds/api/videos/', '')
      self.status = 'completed'
    rescue VideoCreator::Error
      Rails.logger.error { "VideoCreator::Error occured during generating video: #{VideoCreator::Error.to_s}" }
      self.error = "VideoCreator::Error occured during generating video: #{VideoCreator::Error.to_s}"
      self.status = 'error'
    rescue => err
      Rails.logger.error { "Error occured during generating video: #{err.to_s}"}
      self.error = "Error occured during generating video: #{err.to_s}"
      self.status = 'error'
    ensure
     v.cleanup
     self.save
    end
  end
  
  def self.create_from_youtube_callback(rental_unit, params)
    rental_unit.video.destroy if rental_unit.video
    video = rental_unit.build_video(:youtube_id => params[:id], :status => 'completed')
    video.save!
  end
  
  def completed?
    status == 'completed'
  end
  
  def clear_youtube_video
     YoutubeProxy.new.delay.delete_video(self.youtube_id) if self.youtube_id
  end
end
