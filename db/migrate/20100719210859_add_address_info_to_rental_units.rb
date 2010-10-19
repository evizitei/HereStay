class AddAddressInfoToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :address, :string
    add_column :rental_units, :address_2, :string
    add_column :rental_units, :city, :string
    add_column :rental_units, :state, :string
    add_column :rental_units, :zip, :string
  end

  def self.down
    remove_column :rental_units, :zip
    remove_column :rental_units, :state
    remove_column :rental_units, :city
    remove_column :rental_units, :address_2
    remove_column :rental_units, :address
  end
end
