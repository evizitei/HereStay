class ChangeStatusesInBookings < ActiveRecord::Migration
  def self.up
    Booking.all.each do |b|
      status = b.status == "COMPLETE" ? 'reserved' : 'created'
      b.update_attribute(:status, status)
    end
  end

  def self.down
  end
end
