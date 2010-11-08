class BookingMessage < ActiveRecord::Base
  belongs_to :booking
  has_one :rental_unit, :through => "booking"
  
  scope :by_date, :order => 'created_at ASC'
  
  after_create do |message| 
    Delayed::Job.enqueue(BookingMessageNotifier.new(message))
  end
  
  def html_class
    (self.user_fb_id == self.booking.rental_unit.user.fb_user_id ? "owner_message" : "renter_message")
  end
end
