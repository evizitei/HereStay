class CreateRewards < ActiveRecord::Migration
  def self.up
    create_table :rewards do |t|
      t.integer :user_id
      t.integer :booking_id
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :rewards
  end
end
