require 'tmpdir'
require 'fileutils'

class VideoCreator
  class Error < Exception; end
  
  def initialize(*images)
    @remote_images = images
    change_dir
    @images = []
    @duration = 2.to_f
  end
  
  def run!
    begin
      fetch_images
      raise Error, 'No images were found' if @images.blank?
      p cmd
      `#{cmd}`
      upload_to_youtube
    ensure
      # rm_tmpdir
      Dir.chdir Rails.root
    end
  end
  
  protected
  def fetch_images
    @remote_images.each_with_index do |image, index|
      begin
        if (io = open(URI.parse(image))) && io.is_a?(Tempfile)
          file_name = io.base_uri.path.split('/').last
          FileUtils.mv io.path, "#{"%03d" % index}.jpg"
          @images << file_name
        end
      rescue Timeout::Error => e
        next
      end
    end
  end
  
  def output_video_path
    'out.mp4'
  end
  
  #TODO: upload video file to youtube serve and return file id
  def upload_to_youtube
    '123455666'
  end
  
  def sound_track
    File.join(Rails.root, 'tmp', 'sound_track.mp3')
  end
  
  def change_dir
    Dir.chdir tmpdir
  end
  
  def create_tmpdir
    tmpdir = File.join(Rails.root, 'tmp', '123')
    FileUtils.mkdir_p tmpdir
    tmpdir
  end
  
  def rm_tmpdir
    FileUtils.rm_rf tmpdir
  end
  
  # return tmp dir path. create it if the tmp dir is not exits
  def tmpdir
    @tmpdir ||= create_tmpdir
  end
  
  # FIXME: Fix calculation of duration and vframes
  def cmd
    @duration = 2
    k = (1.0/@duration*10).round/10.0
    rate = (1.0/@duration*10).round/10.0
    vframes = (@images.size * @duration * rate ).to_i * 3
    p rate
    p vframes
    "ffmpeg -f image2 -loop_input -r #{rate}  -i %03d.jpg -vframes #{vframes} -y -i #{sound_track}  #{output_video_path}"
  end
end