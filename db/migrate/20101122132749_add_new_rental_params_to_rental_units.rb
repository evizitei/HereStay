class AddNewRentalParamsToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :bedrooms, :integer
    add_column :rental_units, :bathrooms, :integer
    add_column :rental_units, :adults, :integer
    add_column :rental_units, :kids, :integer
  end

  def self.down
    remove_column :rental_units, :bedrooms
    remove_column :rental_units, :bathrooms
    remove_column :rental_units, :adults
    remove_column :rental_units, :kids
  end
end
