class PopulateOwnerFbIdForBookings < ActiveRecord::Migration
  def self.up
    Booking.all.each do |b| 
      b.update_attribute(:owner_fb_id, b.rental_unit.user.fb_user_id)
    end
  end

  def self.down
  end
end
