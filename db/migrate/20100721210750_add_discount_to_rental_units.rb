class AddDiscountToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :percent_discount, :integer
  end

  def self.down
    remove_column :rental_units, :percent_discount
  end
end
