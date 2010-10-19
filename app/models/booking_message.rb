class BookingMessage < ActiveRecord::Base
  belongs_to :booking
  belongs_to :rental_unit
  
  after_create do |message| 
    Delayed::Job.enqueue(BookingMessageNotifier.new(message))
  end
end
