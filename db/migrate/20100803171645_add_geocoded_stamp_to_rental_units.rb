class AddGeocodedStampToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :geocoded_at, :datetime
  end

  def self.down
    remove_column :rental_units, :geocoded_at
  end
end
