class CreateLots < ActiveRecord::Migration
  def self.up
    create_table :lots do |t|
      t.string :title
      t.datetime :start_at
      t.datetime :end_at
      t.integer :min_bid_cents
      t.integer :min_nights
      t.integer :cancel_bid_policy
      t.text :terms
      t.boolean :socially_connected
      t.boolean :stayed_before
      t.integer :property_id

      t.timestamps
    end
  end

  def self.down
    drop_table :lots
  end
end
