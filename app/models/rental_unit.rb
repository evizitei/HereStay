class RentalUnit < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  cattr_reader :per_page
  @@per_page = 5
  attr_accessor :remote_images
  
  has_many :photos, :dependent => :destroy
  has_one :primary_photo, :class_name => 'Photo', :conditions => {:primary => true }
  
  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :primary_photo, :allow_destroy => true, :reject_if => proc { |attributes| attributes['picture'].blank? }
  
  
  has_many :bookings
  has_many :booking_messages, :through => "booking"
  belongs_to :user
  has_many :reservations
  
  validates_presence_of :name
  validates_uniqueness_of :vrbo_id, :scope => :user_id, :if => Proc.new{|a| a.new_record? && a.vrbo_id.present?}
  
  after_create do |unit|
    added_twitter_post
    Delayed::Job.enqueue(RentalUnitGeocoder.new(unit))
  end
  
  before_save do |unit|
    if unit.address_changed? and !unit.new_record?
      Delayed::Job.enqueue(RentalUnitGeocoder.new(unit))
    end
  end
  
  after_save :add_remote_images, :if => :remote_images_present?
  
  searchable do
    text    :name, :default_boost=>2
    text    :description
    text    :address
    text    :address_2
    string  :city
    string  :state
    string  :zip
  end
  
  def initialize(attrs = {})
    super(attrs)
    self.country ||= "USA"
  end
  
  # find uncompleted booking by user or create new if booking not found
  def find_uncompleted_booking_for_user_or_create(user)
    booking = self.bookings.uncompleted.find_by_renter_fb_id(user.fb_user_id)
    booking || self.bookings.create!(:renter_fb_id=> user.fb_user_id, :owner_fb_id => self.fb_user_id )
  end
  
  def youtube_description
    "#{self.description}  BOOK: http://herestay.heroku.com/rental_unit/#{self.id}"
  end
  
  def upload_token
    YoutubeProxy.new.get_upload_token(YoutubeToken.current,self.name,self.youtube_description)
  end
  
  def has_video?
    !self.video_id.nil?
  end
  
  def is_owner?(u)
    self.user == u
  end
  
  # shortcut method to find primary photo. Return nil if primary_photo is mising
  def picture(style = :medium)
    primary_photo.try(:picture).try(:url, style)
  end
  
  # Import listing from vrbo account
  # TODO: handle import errors
  def self.import_from_vrbo!(user)
    rental_units = {:success => [], :fail => []}
    vl = VrboListing.new(user.vrbo_login, user.vrbo_password)
    vl.listings_except(user.rental_units.map{|u| u.vrbo_id}).each do |l|
      new_unit = user.rental_units.build(l)
      if new_unit.save
        rental_units[:success] << new_unit
      else
        rental_units[:fail] << new_unit
      end
    end
    rental_units
  end
  
  # TODO: Dry it using fb_url helper
  def fb_url
    "http://apps.facebook.com/#{Facebook::APP_NAME}/?redirect_to=#{Rack::Utils.escape(rental_unit_path(self))}"
  end
  
  # load attributes from vrbo listing
  # currently it loads following attrs: name, description, address fields
  def load_from_vrbo!
    vl = VrboListing.new(user.vrbo_login, user.vrbo_password)
    self.attributes = vl.lisitng_attributes(self.vrbo_id)
    self.save!
  end
  
  # build new images from array of image urls/
  # def remote_images=(images)
  #   unless images.blank?
  #     existing_remote_photos = self.photos.map{|p| p.image_remote_url}.find_all{|i| i.present?}
  #     new_photos = images - existing_remote_photos
  #     unless new_photos.empty?
  #       self.photos_attributes = new_photos.map{|i| {:image_url => i}}
  #     end
  #   end
  # end
  
  def remote_images_present?
    @remote_images.present? && @remote_images.is_a?(Array)
  end
  
  def add_remote_images
    existing_remote_photos = self.photos.map{|p| p.image_remote_url}.find_all{|i| i.present?}
    new_photos = @remote_images - existing_remote_photos
    Delayed::Job.enqueue(LoadPhoto.new(self.id, new_photos))
  end
  
  def short_url
    BitlyWrapper.short_url(fb_url)
  end
  
  def added_twitter_post
     TwitterWrapper.new(:here_stay).post("#{ActionController::Base.helpers.truncate(name, :length => 50)} has been added. #{price_from} #{short_url}")
  end
  
  def rented_twitter_post(booking)
    TwitterWrapper.new(:here_stay).post("#{ActionController::Base.helpers.truncate(name, :length => 50)} has been rented from #{booking.start_date.to_s(:short_date)} to #{booking.stop_date.to_s(:short_date)} #{short_url}")
  end
  
  def min_price
    [
      self.nightly_high_price, self.nightly_mid_price, self.nightly_low_price,
      self.weekly_high_price, self.weekly_mid_price, self.weekly_low_price
    ].compact.find_all{|p| p > 0.0 }.min
  end
  
  def price_from
    min_price.present? ? "Price from $#{min_price}" : ''
  end
end
