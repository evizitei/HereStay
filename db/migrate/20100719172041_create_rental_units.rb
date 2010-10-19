class CreateRentalUnits < ActiveRecord::Migration
  def self.up
    create_table :rental_units do |t|
      t.string :fb_user_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :rental_units
  end
end
