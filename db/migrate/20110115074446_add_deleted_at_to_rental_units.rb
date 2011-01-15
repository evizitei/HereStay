class AddDeletedAtToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :deleted_at, :datetime
  end

  def self.down
    remove_column :rental_units, :deleted_at
  end
end
