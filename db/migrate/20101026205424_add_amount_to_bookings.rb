class AddAmountToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :amount, :float
  end

  def self.down
    remove_column :bookings, :amount
  end
end
