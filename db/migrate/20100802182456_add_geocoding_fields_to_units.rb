class AddGeocodingFieldsToUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units,:lat,:string
    add_column :rental_units,:long,:string
    add_column :rental_units,:geocoding_success,:boolean
    add_column :rental_units,:geocoded_address,:string
  end

  def self.down
    remove_column :rental_units,:lat
    remove_column :rental_units,:long
    remove_column :rental_units,:geocoding_success
    remove_column :rental_units,:geocoded_address
  end
end
