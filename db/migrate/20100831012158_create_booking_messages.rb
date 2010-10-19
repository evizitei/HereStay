class CreateBookingMessages < ActiveRecord::Migration
  def self.up
    create_table :booking_messages do |t|
      t.string :user_fb_id
      t.integer :booking_id
      t.integer :rental_unit_id
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :booking_messages
  end
end
