class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.integer :user_id, :null => :false
      t.integer :cents, :null => :false
      t.integer :lot_id, :null => :false

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
