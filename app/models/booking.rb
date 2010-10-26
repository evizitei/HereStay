require 'httparty'
class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages
  has_many :discounts
  has_many :rewards
  
  scope :uncompleted, :conditions => ["status is NULL OR status != ?", 'COMPLETE']
  
  # change status without saving (like aasm)
  def complete
    self.status = "COMPLETE"
  end
  
  def confirm!
    UserMailer.booking_confirmation(self).deliver
    self.complete
    self.save!
  end
  
  # upadate record and confirm
  def update_attributes_and_confirm!(attributes)
    self.attributes = attributes
    confirm!
  end
  
  # post message to the user wall and add discount
  def wall_post_by_user!(user)
    HTTParty.post("https://graph.facebook.com/me/feed", {
      :body=>{
        :access_token => user.authorize_signature,
        :message      => "I'm going on a trip, staying at a place I found on HereStay!",
        :picture      => self.rental_unit.picture.url(:thumb),
        :link         => self.rental_unit.fb_url,
        :name         => "Check it out!",
        :caption      => "See for yourself",
        :description  => "Stay at a friends place by finding it on HereStay"}
      }
    )
    discounts.create!(:user_id=>user.id)
  end
end
