class AddPricingInformationToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :pricing, :text
  end

  def self.down
    remove_column :rental_units, :pricing
  end
end
