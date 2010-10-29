require 'httparty'
class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages
  has_many :discounts
  has_many :rewards
  
  after_save :run_on_confirm, :if => :recently_confirmed?
  
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
  
  private
  
  def create_reservation
    rental_unit.reservations.create!(:status => 'RESERVE', :start_at => self.start_date, :end_at => self.stop_date, :first_name => self.renter_name, :notes => self.description, :save_on_remote_server => rental_unit.vrbo_id.present?)
  end
  
  # Post to wall message "(This property) has been rented from (date) to (date)" 
  # when the owner confirms or creates a booking
  def rented_wall_post
    oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s)
    graph = Koala::Facebook::GraphAPI.new(oauth.get_app_access_token)
    graph.put_object(Facebook::APP_ID.to_s, "feed", :message => "#{rental_unit.name} has been rented from #{self.start_date.to_s(:short_date)} to #{self.stop_date.to_s(:short_date)}", :link => rental_unit.fb_url, :name => 'view this property')
  end
  
  def run_on_confirm
    create_reservation
    rented_wall_post
  end
  
  def recently_confirmed?
    status_changed? && self.confirmed?
  end
end
