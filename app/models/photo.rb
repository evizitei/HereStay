# Easy Upload via URL with Paperclip. http://trevorturk.com/2008/12/11/easy-upload-via-url-with-paperclip/

require 'open-uri'
class Photo < ActiveRecord::Base
  attr_accessor :image_url
  
  has_attached_file :picture, :styles => { :medium => "300x300>", :vthumb => "120x90>", :thumb => "100x100>", :mini => "50x50>", :video => ['640x380>', :jpg]},
    :convert_options => {:video => "-gravity center -extent '640x380'"},
    :url => "http://#{HOST}/system/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename"
  
  belongs_to :rental_unit
  
  validates_presence_of :image_remote_url, :if => :image_url_provided?, :message => 'is invalid or inaccessible'
  before_validation :download_remote_image, :if => :image_url_provided?
  
  before_create :assign_primary
  after_destroy :reassign_primary, :if => :primary?
  
  scope :primary, where(:primary => true)
  scope :unlinked_or_for_rental_unit, lambda{|r| where("rental_unit_id IS NULL OR rental_unit_id = ?", r.id) }
  scope :unlinked, where("rental_unit_id IS NULL")
  
  def primary!
    reset_primary
    self.update_attribute(:primary, true)
  end
  
  private
    def reset_primary
      self.rental_unit.photos.primary.update_all({:primary => false}, ["id != ?", self.id])
    end
    
    def assign_primary
      if self.primary?
        reset_primary if self.rental_unit
      elsif !self.rental_unit || !self.rental_unit.photos.primary.exists?
        self.primary = true
      end
    end
    
    def reassign_primary
      if rental_unit && photo = rental_unit.photos.first
        photo.primary! 
      end
    end
    
    
    def image_url_provided?
      !self.image_url.blank?
    end

    def download_remote_image
      self.picture = do_download_remote_image
      self.image_remote_url = image_url
    end

    def do_download_remote_image
      io = open(URI.parse(image_url))
      def io.original_filename; base_uri.path.split('/').last; end
      io.original_filename.blank? ? nil : io
    rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    end
  
end
