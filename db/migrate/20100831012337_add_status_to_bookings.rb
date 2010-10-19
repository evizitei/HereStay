class AddStatusToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :status, :string
  end

  def self.down
    remove_column :bookings, :status
  end
end
