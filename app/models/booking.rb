require 'httparty'
class Booking < ActiveRecord::Base
  include AASM
  
  aasm_column :status
  aasm_initial_state :created  
  aasm_state :created # just created
  aasm_state :reserved, :enter => :do_reserve!  # reserved by owner
  aasm_state :canceled_by_owner, :enter => :do_cancel_by_owner!
  aasm_state :canceled_by_renter, :enter => :do_cancel_by_renter!
  
  aasm_event :reserve do
    transitions :to => :reserved, :from => [:created], :guard => :valid?
  end
  
  aasm_event :cancel_by_renter do
    transitions :to => :canceled_by_renter, :from => [:created, :reserved]
  end
  
  aasm_event :cancel_by_owner do
    transitions :to => :canceled_by_owner, :from => [:created, :reserved]
  end
  
  belongs_to :rental_unit
  has_many :booking_messages, :dependent => :destroy
  has_many :discounts
  has_many :rewards
  has_one  :reservation, :dependent => :destroy
  has_many :booking_charges, :dependent => :destroy, :as => :document
  
  validate :check_dates
  validate :validate_dates, :if => :require_validate_dates?
  
  before_save :update_reservation, :unless => :status_changed?
  
  scope :except, lambda{|r| where("id != ?", r.id) }
  scope :for_user, lambda{|u| where("owner_fb_id = ? OR renter_fb_id = ?", u.fb_user_id, u.fb_user_id)}
  scope :for_renter, lambda{|u| where("renter_fb_id = ?", u.fb_user_id)}
  scope :started, lambda{where(["start_date <= ?", Time.zone.now])}
  scope :without_booking_charges, joins('LEFT JOIN "funds" ON "funds"."document_id" = "bookings"."id" AND "funds"."document_type" = \'Booking\' AND "funds"."type" = \'BookingCharge\'').where({:funds => {:id => nil}})
  
  scope :not_reserved, :conditions => {:status => 'created'}
  scope :confirmed, :conditions => ["confirmed_by_renter_at IS NOT NULL"]
  scope :not_confirmed, :conditions => ["confirmed_by_renter_at IS NULL"]
  scope :canceled, :conditions => {:status => ['canceled_by_owner', 'canceled_by_renter']}
  scope :active, :conditions => {:status => ['created', 'reserved']}
  
  # upadate record and reserve
  def update_attributes_and_reserve(attributes)
    self.reserve! if self.update_attributes(attributes)
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
    self.save
  end
  
  def other_user_than(user)
    fb_id = [self.owner_fb_id,self.renter_fb_id].select{|id| id != user.fb_user_id}.first
    User.find_by_fb_user_id(fb_id)
  end
  
  def cancel_by(user)
    if self.owner_fb_id == user.fb_user_id
      self.cancel_by_owner! 
    elsif self.renter_fb_id == user.fb_user_id
      self.cancel_by_renter!
    end      
  end
  
  def can_be_canceled?
    self.created? || (self.reserved? && self.reservation && Time.now < self.reservation.start_at)    
  end
  
  def cents
    (amount*100).to_i
  end
  
  def owner
    rental_unit.user
  end
  
  def renter
    User.find_by_fb_user_id(self.renter_fb_id)
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

  def recently_reserved?
    status_changed? && self.reserved?
  end
  
  # validate dates for other booking or reservation in this period when booking confirmed and dates are changes
  def require_validate_dates?
    (self.created? || self.reserved?) && (start_date_changed? || stop_date_changed?)
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
    rental_unit.bookings.reserved.exists?([" stop_date > ? AND start_date < ? AND id != ? ", self.start_date.to_s(:db), self.stop_date.to_s(:db), self.id || 0])
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
  
  # Charge booking fee
  # Find all reserved booking which does not have booking charges
  # Should be run by cron every day
  def self.charge_booking_fee
    Booking.reserved.started.without_booking_charges.each do |booking|
      booking.booking_charges.create!
    end
  end
  
  before_create :set_owner_fb_id
  def set_owner_fb_id
    self.owner_fb_id = self.rental_unit.user.fb_user_id
  end
  
  def do_reserve! 
    create_reservation
    FacebookProxy.delay.post_unit_rented(self)
    TwitterWrapper.post_unit_rented(self)
    UserMailer.booking_confirmation(self).deliver if self.renter_fb_id
  end
  
  def do_cancel_by_renter!
    UserMailer.booking_canceled_notification(self, self.renter_fb_id).deliver
    UserMailer.booking_canceled_by_renter_notification(self).deliver
  end
  
  def do_cancel_by_owner!
    UserMailer.booking_canceled_notification(self, self.owner_fb_id).deliver
    UserMailer.booking_canceled_by_owner_notification(self).deliver
  end
end
