class AddFbFriendsIdsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_friend_ids, :text
  end

  def self.down
    remove_column :users, :fb_friend_ids
  end
end
