class AddUpdateTwitterAndUpdateFbWallToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :update_twitter, :boolean, :default => false, :null => false
    add_column :users, :update_fb_wall, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :update_fb_wall
    remove_column :users, :update_twitter
  end
end
