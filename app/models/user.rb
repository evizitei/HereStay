class User < ActiveRecord::Base
  serialize :fb_friend_ids, Array
  
  has_many :discounts
  has_many :rental_units
  has_many :rewards
  has_many :bookings, :through => :rental_units, :readonly => false
  has_many :messages,:class_name=>"BookingMessage",:foreign_key=>"recipient_id"
  has_many :fb_streams, :class_name => "UserFbStream"
  has_many :comments
  
  before_validation :capture_fb_profile, :if => :need_capture_fb_profile?
  
  scope :online , lambda {where(["last_poll_time > ?", (Time.zone.now - 1.minutes)])}
  scope :except, lambda {|u| where("id != ?", u.id)}
  
  # find or create user by fb-uid and update his oauth token and session data
  def self.for(oauth_obj)
    if oauth_obj && oauth_obj['uid'].present?
      user = User.find_or_create_by_fb_user_id(oauth_obj['uid']).tap do |user|
        user.authorize_signature = oauth_obj["access_token"]
        user.session_expires_at = oauth_obj["expires"]
        user.session_key = oauth_obj["session_key"]
        user.save(:validate => false) if user.changed?
      end
      
      if user 
        # capture user email and location from FB profile
        Delayed::Job.enqueue(FbUserDataFetcher.new(user.id)) if user.email.blank? || user.need_update_fb_location?
        # capture facebook friend ids
        Delayed::Job.enqueue(FbFriendsFetcher.new(user.id)) if user.fb_friend_ids.nil?
      end
      
      user
    end
  end
  
  def initialize(attrs={})
    super({})
    self.redeemed_rewards ||= 0.0
    self.last_poll_time ||= Time.zone.now
    self.sms_starting_at ||= Time.parse("07:00 AM")
    self.sms_ending_at ||= Time.parse("09:00 PM")
  end
  
  def access_token
    self.authorize_signature
  end
  
  def remove_twitter=(attrs)
    if attrs
      self.twitter_token = nil
      self.twitter_secret = nil
      self.twitter_name = nil
    end
  end
  
  def twitter?
    self.twitter_name? && self.twitter_token? && self.twitter_secret?
  end
  
  def pulse!
    update_attributes!(:last_poll_time=>Time.zone.now)
  end
  
  def deliver_message!(message)
    if !self.online? and self.phone
      Moonshado::Sms.new(self.phone,message).deliver_sms
    end
  end
  
  def online?
    return false if self.last_poll_time.nil?
    self.last_poll_time > (Time.zone.now - 1.minutes)
  end
  
  def available_by_phone?
    return false if self.phone.blank? or self.sms_starting_at.nil? or self.sms_ending_at.nil?
    now = DateTime.now
    start = DateTime.parse("#{now.strftime("%m/%d/%Y")} #{self.sms_starting_at.strftime("%H:%M")}") 
    stop = DateTime.parse("#{now.strftime("%m/%d/%Y")} #{self.sms_ending_at.strftime("%H:%M")}")
    stop = stop + 24.hours if stop < start
    now > start and now < stop
  end
  
  def availability_message
    return "online!" if online?
    return "available by phone." if available_by_phone?
    "offline."
  end
  
  def get_fb_friend_ids
    res = FacebookProxy.new(self.access_token).get_connections('me', 'friends', :fields => "id")
    self.fb_friend_ids = res.map{|r| r["id"].to_i}
  end
  
  def get_fb_friend_ids!
    get_fb_friend_ids
    save(:validate => false)
  end
  
  # capture FB data from FB profile and retrieve coordinates with Google API if fb_location is present
  def capture_fb_profile_data!
    fb_profile = FacebookProxy.new(self.access_token).get_object('me')
    self.email = fb_profile['email']
    if fb_profile['location']
      self.fb_location = fb_profile['location']['name']
      self.fb_location_update_at = Time.now
      if self.fb_location_changed? || !self.valid_country?
        self.valid_country = false
        if res = GoogleApi.geocoder(self.fb_location)
          self.fb_lat = res[:lat]
          self.fb_lng = res[:long]
          self.valid_country = true if res[:geocoded_address] =~ /USA/
        end
        
      end
    elsif fb_profile['hometown']
      self.fb_location = fb_profile['hometown']['name']
      self.fb_location_update_at = Time.now
      if self.fb_location_changed?
        self.valid_country = false
        if res = GoogleApi.geocoder(self.fb_location)
          self.fb_lat = res[:lat]
          self.fb_lng = res[:long]
          self.valid_country = true if res[:geocoded_address] =~ /USA/
        end
      end
    end
    save(:validate => false)
  end
  
  # return true if fb_location empty or last attempt to update fb_location was run more than 1 day ago
  # fb_location_update_at will allow don't update more than once a day
  def need_update_fb_location?
    fb_location.blank? && (fb_location_update_at.nil? || fb_location_update_at > 1.day.ago)
  end
  
  def mutual_friends_with(user)
    if !self.fb_friend_ids.blank? && !user.fb_friend_ids.blank?
      self.fb_friend_ids & user.fb_friend_ids
    end
  end
  
  def friend_of?(user)
    if !self.fb_friend_ids.blank?
      self.fb_friend_ids.include?(user.fb_user_id.to_i)
    end
  end
  
  def subscription
    Subscription.new({:plan => self.subscription_plan, :user => self})
  end
  
  def subscribed?
    subscription_plan.present?
  end
  
  def has_advanced_subscrition?
    subscribed? && subscription_plan == 'advanced'
  end
  
  def post_twitter_updates?
    twitter? && has_advanced_subscrition? && update_twitter?
  end
  
  def post_fb_wall_updates?
    has_advanced_subscrition? && update_fb_wall?
  end
  
  private
  def need_capture_fb_profile?
    use_fb_profile_changed? && use_fb_profile?
  end
  
  def capture_fb_profile
    fb_profile = FacebookProxy.new(self.access_token).get_object('me')
    self.first_name = fb_profile['first_name']
    self.last_name = fb_profile['last_name']
    self.middle_initial = nil
    self.company = nil
  end
  
  public
  def get_stream_publishing(post_id)
    if post = FacebookProxy.new(self.access_token).get_object(post_id)
      post['message']
    end  
  end
  
  def get_latlng?
    !self.fb_lat.blank? && !self.fb_lng.blank?
  end
  
  def get_latlng
    self.capture_fb_profile_data! unless self.get_latlng?
    self.valid_country? && self.get_latlng?
  end
  
  def get_last_comment(xid)
    Koala::Facebook::RestAPI.new(self.access_token).fql_query("select xid, object_id, post_id, fromid, time, text, id, username, reply_xid  from comment where xid  = '#{xid}' and fromid = #{self.fb_user_id}").first
  end
  
  def store_last_comment_for(rental_unit)
    comment = get_last_comment("here_stay_unit_#{rental_unit.id}")
    rental_unit.comments.create(:user_id => self.id, 
                                :fb_user_id => self.fb_user_id,
                                :fb_id => comment['id'],
                                :text => comment['text'],
                                :time => Time.at(comment['time'])
                                )
  end
end
