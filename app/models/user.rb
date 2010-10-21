class User < ActiveRecord::Base
  has_many :discounts
  
  # find or create user by fb-uid and update his oauth token and session data
  def self.for(oauth_obj)
    unless oauth_obj['uid'].blank?
      User.find_or_create_by_fb_user_id(oauth_obj['uid']).tap do |user|
        user.authorize_signature = oauth_obj["access_token"]
        user.session_expires_at = oauth_obj["expires"]
        user.session_key = oauth_obj["session_key"]
        user.save(:validate => false)
      end
    end
  end
end
