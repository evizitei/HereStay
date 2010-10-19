class CreateBookings < ActiveRecord::Migration
  def self.up
    create_table :bookings do |t|
      t.integer :rental_unit_id
      t.string :owner_fb_id
      t.string :renter_name
      t.string :renter_fb_id
      t.date :start_date
      t.date :stop_date
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :bookings
  end
end
