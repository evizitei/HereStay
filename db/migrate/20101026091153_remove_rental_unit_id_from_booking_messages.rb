class RemoveRentalUnitIdFromBookingMessages < ActiveRecord::Migration
  def self.up
    remove_column :booking_messages, :rental_unit_id
  end

  def self.down
    add_column :booking_messages, :rental_unit_id, :integer
  end
end
