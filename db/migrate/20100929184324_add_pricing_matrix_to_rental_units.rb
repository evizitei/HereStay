class AddPricingMatrixToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :nightly_high_price, :float
    add_column :rental_units, :nightly_mid_price, :float
    add_column :rental_units, :nightly_low_price, :float
    add_column :rental_units, :weekly_high_price, :float
    add_column :rental_units, :weekly_mid_price, :float
    add_column :rental_units, :weekly_low_price, :float
  end

  def self.down
    remove_column :rental_units, :weekly_low_price
    remove_column :rental_units, :weekly_mid_price
    remove_column :rental_units, :weekly_high_price
    remove_column :rental_units, :nightly_low_price
    remove_column :rental_units, :nightly_mid_price
    remove_column :rental_units, :nightly_high_price
  end
end
