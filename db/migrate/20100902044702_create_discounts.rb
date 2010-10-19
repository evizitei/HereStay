class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.integer :user_id
      t.integer :booking_id

      t.timestamps
    end
  end

  def self.down
    drop_table :discounts
  end
end
