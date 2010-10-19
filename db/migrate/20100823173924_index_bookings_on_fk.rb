class IndexBookingsOnFk < ActiveRecord::Migration
  def self.up
    add_index :bookings,:rental_unit_id
  end

  def self.down
    remove_index :bookings,:rental_unit_id
  end
end
