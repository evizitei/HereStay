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
  end
  before_create :set_recipient
  
  
  def html_class
    (self.user_fb_id == self.booking.rental_unit.user.fb_user_id ? "owner_message" : "renter_message")
  end
  
  
  def set_recipient
    recipient_fb_id = self.user_fb_id == self.booking.renter_fb_id ? self.booking.rental_unit.user.fb_user_id : booking.renter_fb_id
    self.recipient = User.where({:fb_user_id => recipient_fb_id}).first
  end
end
