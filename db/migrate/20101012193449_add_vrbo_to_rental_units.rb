class AddVrboToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :vrbo_id, :string
  end

  def self.down
    remove_column :rental_units, :vrbo_id
  end
end
