class Booking < ActiveRecord::Base
  belongs_to :rental_unit
  has_many :booking_messages
  has_many :discounts
  
  def confirm!
    UserMailer.booking_confirmation(self).deliver
    self.status = "COMPLETE"
    self.save!
  end
end
