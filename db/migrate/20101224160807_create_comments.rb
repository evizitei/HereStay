class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer  :user_id
      t.string   :fb_user_id
      t.integer  :rental_unit_id
      t.text     :text
      t.string   :fb_id
      t.integer  :likes
      t.datetime :time

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
