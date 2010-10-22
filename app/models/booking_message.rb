class BookingMessage < ActiveRecord::Base
  belongs_to :booking
  belongs_to :rental_unit
  
  scope :by_date, :order => 'created_at ASC'
  
  after_create do |message| 
    Delayed::Job.enqueue(BookingMessageNotifier.new(message))
  end
end
