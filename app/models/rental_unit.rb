class RentalUnit < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 5
  
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                      :storage => :s3,:s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                      :path => ":attachment/:id/:style/:basename.:extension",
                      :s3_host_alias => "s3.micasa-fb.com", 
                      :bucket => "s3.micasa-fb.com", 
                      :url=>":s3_alias_url"
  
  has_many :photos
  has_many :bookings
  has_many :booking_messages
  
  before_save do |unit| 
    if unit.address_changed?
      Delayed::Job.enqueue(RentalUnitGeocoder.new(unit))
    end
  end
  
  searchable do
    text    :name, :default_boost=>2
    text    :description
    text    :address
    text    :address_2
    string  :city
    string  :state
    string  :zip
  end
  
  def fb_url
    "http://apps.facebook.com/micasasucasa/my_rental_units/show?id=#{self.id}"
  end
  
  def user
    @user ||= User.find_by_fb_user_id(fb_user_id)
  end
  
  def youtube_description
    "#{self.description}  BOOK: #{self.fb_url}"
  end
  
  def upload_token
    YoutubeProxy.new.get_upload_token(YoutubeToken.current,self.name,self.youtube_description)
  end
  
  def has_video?
    !self.video_id.nil?
  end
  
end
