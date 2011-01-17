class AddTerminatedToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :terminated, :boolean, :default => false
  end

  def self.down
    remove_column :bookings, :terminated
  end
end
