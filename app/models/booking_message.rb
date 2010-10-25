class BookingMessage < ActiveRecord::Base
  belongs_to :booking
  
  scope :by_date, :order => 'created_at ASC'
  
  after_create do |message| 
    Delayed::Job.enqueue(BookingMessageNotifier.new(message))
  end
end
