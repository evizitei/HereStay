class AddFbLocationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_location, :string
    add_column :users, :fb_location_update_at, :datetime
    add_column :users, :fb_lng, :string
    add_column :users, :fb_lat, :string
  end

  def self.down
    remove_column :users, :fb_lat
    remove_column :users, :fb_lng
    remove_column :users, :fb_location
    remove_column :users, :fb_location_update_at
  end
end
