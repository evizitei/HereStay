class AddAmenitiesFieldsToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :balcony, :boolean, :default => false
    add_column :rental_units, :dishwasher, :boolean, :default => false
    add_column :rental_units, :fireplace, :boolean, :default => false
    add_column :rental_units, :hardwood_floors, :boolean, :default => false
    add_column :rental_units, :patio, :boolean, :default => false
    add_column :rental_units, :refrigerator, :boolean, :default => false
    add_column :rental_units, :microwave, :boolean, :default => false
    add_column :rental_units, :washer_dryer, :boolean, :default => false
    add_column :rental_units, :clubhouse, :boolean, :default => false
    add_column :rental_units, :exercise_room, :boolean, :default => false
    add_column :rental_units, :on_site_laundry, :boolean, :default => false
    add_column :rental_units, :on_site_manager, :boolean, :default => false
    add_column :rental_units, :security_gate, :boolean, :default => false
    add_column :rental_units, :swimming_pool, :boolean, :default => false
    add_column :rental_units, :tennis_courts, :boolean, :default => false
    add_column :rental_units, :parking, :boolean, :default => false
    add_column :rental_units, :wifi, :boolean, :default => false
    
    add_column :rental_units, :unit_other, :string
    add_column :rental_units, :building_other, :string
    
    add_column :rental_units, :floors, :integer
    add_column :rental_units, :located_on_floor, :integer
    add_column :rental_units, :year_built, :string
    add_column :rental_units, :sq_footage, :string
  end

  def self.down
    remove_column :rental_units, :balcony
    remove_column :rental_units, :dishwasher
    remove_column :rental_units, :fireplace
    remove_column :rental_units, :hardwood_floors
    remove_column :rental_units, :patio
    remove_column :rental_units, :refrigerator
    remove_column :rental_units, :microwave
    remove_column :rental_units, :washer_dryer
    remove_column :rental_units, :clubhouse
    remove_column :rental_units, :exercise_room
    remove_column :rental_units, :on_site_laundry
    remove_column :rental_units, :on_site_manager
    remove_column :rental_units, :security_gate
    remove_column :rental_units, :swimming_pool
    remove_column :rental_units, :tennis_courts
    remove_column :rental_units, :parking
    remove_column :rental_units, :wifi
    
    remove_column :rental_units, :unit_other
    remove_column :rental_units, :building_other
    
    remove_column :rental_units, :floors
    remove_column :rental_units, :located_on_floor
    remove_column :rental_units, :year_built
    remove_column :rental_units, :sq_footage
  end
end
