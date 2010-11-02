class AddBookingIdToReservations < ActiveRecord::Migration
  def self.up
    add_column :reservations, :booking_id, :integer
  end

  def self.down
    remove_column :reservations, :booking_id
  end
end
