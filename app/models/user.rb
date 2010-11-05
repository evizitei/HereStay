class User < ActiveRecord::Base
  has_many :discounts
  has_many :rental_units
  has_many :rewards
  has_many :bookings, :through => :rental_units
  # find or create user by fb-uid and update his oauth token and session data
  def self.for(oauth_obj)
    if oauth_obj && oauth_obj['uid'].present?
      User.find_or_create_by_fb_user_id(oauth_obj['uid']).tap do |user|
        user.authorize_signature = oauth_obj["access_token"]
        user.session_expires_at = oauth_obj["expires"]
        user.session_key = oauth_obj["session_key"]
        user.save(:validate => false)
      end
    end
  end
  
  def initialize(attrs={})
    super({})
    self.redeemed_rewards ||= 0.0
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
end
