class AddCountryToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :country, :string
  end

  def self.down
    remove_column :rental_units, :country
  end
end
