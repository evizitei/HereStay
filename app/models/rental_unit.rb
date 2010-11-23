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
  # geocoding address and validate
  validate :geocode_address, :if => :full_address_changed?
  validates :bedrooms, :bathrooms, :adults, :kids, :numericality => true, :allow_blank => true
  
  after_create do |unit|
    TwitterWrapper.post_unit_added(unit)
  end
  
  after_save :add_remote_images, :if => :remote_images_present?
  
  searchable do
    text    :name, :default_boost=>2
    text    :description
    text    :address
    text    :address_2
    time  :created_at
    string  :city
    string  :state
    string  :zip
    integer :bedrooms
    integer :bathrooms
    integer :adults
    integer :kids
    long :owner_fb_id do |unit|
      unit.user.fb_user_id
    end
    long :fb_friend_ids, :multiple => true do |unit|
      unit.user.fb_friend_ids
    end
    integer :search_min_price do |unit|
      (unit.weekly_low_price.to_f/7).floor unless unit.weekly_low_price.blank?
    end
    integer :search_max_price do |unit|
      (unit.nightly_high_price.to_f).ceil unless unit.weekly_high_price.blank?
    end
  end
  
  # List all listings and order the friends' lisitngs first
  def self.friends_first(fb_seeker_id, friend_ids, page)
    friend_ids = [0] if friend_ids.blank?
    self.search do
      keywords "*:*" do
        
        # Boost listing if it belongs to friend
        boost(3) do
          with(:fb_friend_ids, fb_seeker_id)
        end
        
        # Boost the listing if it belongs to friend of friends
        # but do not boost if the listing belongs to seeker
        boost(2) do
          with(:fb_friend_ids).any_of(friend_ids)
          without(:owner_fb_id, fb_seeker_id)
        end
      end
      
      order_by(:score, :desc)
      order_by(:created_at, :desc)
      paginate :page => page
    end
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
    "#{self.description}  BOOK: #{fb_url}"
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
  
  def min_price
    [
      self.nightly_high_price, self.nightly_mid_price, self.nightly_low_price,
      self.weekly_high_price, self.weekly_mid_price, self.weekly_low_price
    ].compact.find_all{|p| p > 0.0 }.min
  end
  
  def price_from
    min_price.present? ? "Price from $#{min_price}" : ''
  end
  
  def full_address
    [address, address_2, city, state, zip, country].find_all{|a| a.present?}.join(', ')
  end
  
  private
  def full_address_changed?
    ['address', 'address_2', 'city', 'state', 'zip', 'country'].any?{|a| self.send("#{a}_changed?")}
  end
  
  # geocode adrress
  def geocode_address
    res = GoogleApi.geocoder(full_address)
    if res
      self.attributes = res
      self.geocoding_success = true
      self.geocoded_at = Time.now
    else
      errors.add(:base, "Sorry, we were unable to geocode that address")
    end
  end
  
  def self.advanced_search(params, user)
    self.search do
      keywords(params[:search])
      paginate(:page =>(params[:page] || 1), :per_page => 5)
      
      if params[:advanced] == '1'
        if params[:range_bedrooms_to].to_i > 4
          with(:bedrooms).greater_than(params[:range_bedrooms_from].to_i - 1) unless params[:range_bedrooms_from].to_i == 1
        else  
          with(:bedrooms, params[:range_bedrooms_from].to_i..params[:range_bedrooms_to].to_i)
        end
        
        if params[:range_bathes_to].to_i > 4
          with(:bathrooms).greater_than(params[:range_bathes_from].to_i - 1) unless params[:range_bathes_from].to_i == 0
        else
          with(:bathrooms, params[:range_bathes_from].to_i..params[:range_bathes_to].to_i)
        end
        
        if params[:range_adults_to].to_i > 4
          with(:adults).greater_than(params[:range_adults_from].to_i - 1) unless params[:range_adults_from].to_i == 0
        else
          with(:adults, params[:range_adults_from].to_i..params[:range_adults_to].to_i)
        end
        
        if params[:range_kids_to].to_i > 4
          with(:kids).greater_than(params[:range_kids_from].to_i - 1) unless params[:range_kids_from].to_i == 0
        else
          with(:kids, params[:range_kids_from].to_i..params[:range_kids_to].to_i)
        end
        
        if params[:range_budget_from].to_i > RentalUnit.min_price || params[:range_budget_to].to_i < RentalUnit.max_price
          with(:search_min_price, params[:range_budget_from].to_f..params[:range_budget_to].to_f)
          with(:search_max_price, params[:range_budget_from].to_f..params[:range_budget_to].to_f)
        end
        
        # Owner should be a friend or friend of friend
        if params[:friend_only] && user && user.fb_friend_ids.present?
          friend_ids = user.fb_friend_ids << user.fb_user_id
          with(:fb_friend_ids).any_of(friend_ids)
          without(:owner_fb_id, user.fb_user_id)
        end
      end
    
    end
  end
  
  def self.min_price
    p = RentalUnit.minimum(:weekly_low_price)
    (p/7).floor unless p.nil?
  end
  
  def self.max_price
    p = RentalUnit.maximum(:nightly_high_price)
    (p.to_f).ceil unless p.nil?
  end
end