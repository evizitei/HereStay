class AddTimestampForRenterConfirmationToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :confirmed_by_renter_at, :timestamp
  end

  def self.down
    remove_column :bookings, :confirmed_by_renter_at
  end
end
