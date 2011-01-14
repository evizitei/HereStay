class AddFeaturedToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :featured, :boolean, :default => false
  end

  def self.down
    remove_column :rental_units, :featured
  end
end
