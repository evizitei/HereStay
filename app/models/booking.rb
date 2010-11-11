require 'httparty'
class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages, :dependent => :destroy
  has_many :discounts
  has_many :rewards
  has_one  :reservation, :dependent => :destroy
  
  validate :check_dates
  validate :validate_dates, :if => :require_validate_dates?
  
  before_save :update_reservation, :unless => :recently_confirmed?
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
        :picture      => self.rental_unit.picture || '',
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
    build_reservation(:status => 'RESERVE', :start_at => self.start_date.to_s(:db), :end_at => self.stop_date.to_s(:db), :first_name => self.renter_name, :notes => self.description, :save_on_remote_server => rental_unit.vrbo_id.present?, :rental_unit => rental_unit)
    reservation.save!
  end
  
  def update_reservation
    if reservation.present?
      reservation.update_attributes(:start_at => self.start_date.to_s(:db), :end_at => self.stop_date.to_s(:db), :first_name => self.renter_name, :notes => self.description, :save_on_remote_server => rental_unit.vrbo_id.present?)
    end
  end
  
  # Post to wall message "(This property) has been rented from (date) to (date)" 
  # when the owner confirms or creates a booking
  # TODO: move to background work
  def rented_wall_post
    FacebookProxy.new(:here_stay).put_object(:here_stay, "feed",
      :message => "#{rental_unit.name} has been rented from #{self.start_date.to_s(:short_date)} to #{self.stop_date.to_s(:short_date)}",
      :link => rental_unit.fb_url,
      :name => 'view this property',
      :picture=> rental_unit.picture(:medium) || ''
    )
  end
  
  def run_on_confirm
    create_reservation
    rented_wall_post
    TwitterWrapper.post_unit_rented(self)
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
    rental_unit.bookings.completed.exists?([" stop_date > ? AND start_date < ? AND id != ? ", self.start_date.to_s(:db), self.stop_date.to_s(:db), self.id || 0])
  end
  
  # don't allow create more than one reservation with status UNAVAILABLE or RESERVE in same period
  def validate_for_another_reservation
    if start_date && stop_date
      errors.add(:start_date, 'These dates are unavailable for booking.') if exists_other_reservations_in_same_period?
    end
  end
  
  def exists_other_reservations_in_same_period?
    rental_unit.reservations.busy.exists?([" ? < end_at AND ? > start_at AND booking_id != ?", self.start_date.to_datetime, self.stop_date.to_datetime, self.id||0])
  end
end
