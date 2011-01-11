require 'tmpdir'
require 'fileutils'

class VideoCreator
  class Error < Exception; end
  
  def initialize(images)
    @remote_images = images
    change_dir
    @images = []
    @duration = 2.to_f
    @youtube_options = {}
  end
  
  def process!
    fetch_images
    raise Error, 'No images were found' if @images.blank?
    `#{cmd}`
  end
  
  def path_to_file
    output_video_path
  end
  
  def cleanup
    rm_tmpdir
  end
  
  protected
  def output_video_path
    @output_video_path ||= File.join(tmpdir, 'video.mp4')
  end
  
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
  
  def sound_track
    File.join(Rails.root, 'tmp', 'sound_tracks', 'sound_track.mp3')
  end
  
  def change_dir
    Dir.chdir tmpdir
  end
  
  def create_tmpdir
    tmpdir = File.join(Rails.root, 'tmp', rand(1000000).to_s)
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
    # p rate
    # p vframes
    "ffmpeg -f image2 -loop_input -r #{rate}  -i %03d.jpg -vframes #{vframes} -y -i #{sound_track}  #{output_video_path}"
  end
end