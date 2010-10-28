require 'httparty'
class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages
  has_many :discounts
  has_many :rewards
  
  after_save :create_reservation_on_confirm
  
  scope :uncompleted, :conditions => ["status is NULL OR status != ?", 'COMPLETE']
  
  # change status without saving (like aasm)
  def complete
    self.status = "COMPLETE"
  end
  
  def confirm!
    UserMailer.booking_confirmation(self).deliver
    self.complete
    create_reservation
    self.save!
  end
  
  def confirmed?
    self.status == "COMPLETE"
  end
  
  # upadate record and confirm
  def update_attributes_and_confirm!(attributes)
    self.attributes = attributes
    confirm!
  end
  
  def promotional_fee
    if self.amount
      (((self.amount * 0.05) * 100).round.to_f / 100)
    else
      0.0
    end
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
  
  def confirm_by_renter!
    self.confirmed_by_renter_at = DateTime.now
    self.save!
  end
  
  def create_reservation_on_confirm
    if status_changed? && self.confirmed?
      rental_unit.reservations.create!(:status => 'RESERVE', :start_at => self.start_date, :end_at => self.stop_date, :first_name => self.renter_name, :notes => self.description, :save_on_remote_server => rental_unit.vrbo_id.present?)
    end
  end
end
