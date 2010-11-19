class User < ActiveRecord::Base
  serialize :fb_friend_ids, Array
  
  has_many :discounts
  has_many :rental_units
  has_many :rewards
  has_many :bookings, :through => :rental_units
  has_many :messages,:class_name=>"BookingMessage",:foreign_key=>"recipient_id"
  
  before_validation :capture_fb_profile, :if => :need_capture_fb_profile?
  
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
        # capture user email from FB profile
        Delayed::Job.enqueue(FbEmailFetcher.new(user.fb_user_id)) if user.email.blank?
        
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
    message.update_attributes!(:recipient=>self)
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
end
