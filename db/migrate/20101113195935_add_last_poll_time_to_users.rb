class AddLastPollTimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_poll_time, :timestamp
  end

  def self.down
    remove_column :users, :last_poll_time
  end
end
