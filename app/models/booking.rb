require 'httparty'
class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages
  has_many :discounts
  has_many :rewards
  
  validate :check_dates
  validate :validate_dates, :if => :require_validate_dates?
  
  after_save :run_on_confirm, :if => :recently_confirmed?
  
  scope :uncompleted, :conditions => ["status is NULL OR status != ?", 'COMPLETE']
  scope :completed, where(:status => 'COMPLETE')
  scope :except, lambda{|r| where("id != ?", r.id) }
  
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
  def update_attributes_and_confirm(attributes)
    self.attributes = attributes
    complete
    save
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
        :picture      => self.rental_unit.primary_photo ? self.rental_unit.primary_photo.picture.url(:thumb) : nil,
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
  
  # validate dates for other booking or reservation in this period when booking confirmed and dates are changes
  def require_validate_dates?
    self.confirmed? && (self.status_changed? || start_date_changed? || stop_date_changed?)
  end
  
  # don't allow to start_at be greater than end_at
  def check_dates
    if start_date && stop_date
      errors.add(:end_date, 'should be greater than start date') if stop_date <= start_date
    end
  end
  
  def validate_dates
    validate_for_another_booking
    validate_for_another_reservation
  end
  
  # don't allow create more than one reservation with status UNAVAILABLE or RESERVE in same period
  def validate_for_another_booking
    if start_date && stop_date
      errors.add(:start_date, 'Another booking already exists for these dates.') if exists_other_booking_in_same_period?
    end
  end
  
  def exists_other_booking_in_same_period?
    rental_unit.bookings.except(self).completed.exists?([" ? < start_date AND ? > stop_date", self.start_date, self.stop_date])
  end
  
  # don't allow create more than one reservation with status UNAVAILABLE or RESERVE in same period
  def validate_for_another_reservation
    if start_date && stop_date
      errors.add(:start_date, 'These dates are unavailable for booking.') if exists_other_reservations_in_same_period?
    end
  end
  
  def exists_other_reservations_in_same_period?
    rental_unit.reservations.busy.exists?([" ? < end_at AND ? > start_at", self.start_date, self.stop_date])
  end
end
