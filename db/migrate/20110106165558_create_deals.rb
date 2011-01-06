class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.date :start_on
      t.date :end_on
      t.integer :cents, :default => 0
      t.integer :user_id
      t.integer :rental_unit_id
      t.integer :percent
      t.string :status, :default => "active"
      t.timestamps
    end
  end

  def self.down
    drop_table :deals
  end
end
