class BookingMessage < ActiveRecord::Base
  belongs_to :booking
  belongs_to :recipient,:class_name=>"User"
  has_one :rental_unit, :through => "booking"
  
  scope :by_date, :order => 'created_at ASC'
  scope :last_messages, lambda { |last_message| 
    where(["id > ?", last_message]) unless last_message.blank?
  }
  scope :except, lambda { |b_id| 
    where(["booking_id != ?", b_id.to_i]) unless b_id.blank?
  }
  
  after_create do |message| 
    Delayed::Job.enqueue(BookingMessageNotifier.new(message))
    self.send_sms!
  end
  before_create :set_recipient
  
  
  def html_class
    (self.user_fb_id == self.booking.rental_unit.user.fb_user_id ? "owner_message" : "renter_message")
  end
  
  
  def set_recipient
    recipient_fb_id = self.user_fb_id == self.booking.renter_fb_id ? self.booking.rental_unit.user.fb_user_id : booking.renter_fb_id
    self.recipient = User.where({:fb_user_id => recipient_fb_id}).first
  end
  
  # send SMS to recipient if he is offline
  def send_sms!
    recipient.deliver_message!("You have a new message in HereStay: #{mobile_discuss_booking_url(message.booking_id, :user_id => message.recipient_id)}") if !recipient.online? and recipient.available_by_phone?
  end
end
