class IndexUsersByFacebookId < ActiveRecord::Migration
  def self.up
    add_index :users,:fb_user_id
  end

  def self.down
    remove_index :users,:fb_user_id
  end
end
