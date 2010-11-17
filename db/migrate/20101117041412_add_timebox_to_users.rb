class AddTimeboxToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sms_starting_at, :time
    add_column :users, :sms_ending_at, :time
  end

  def self.down
    remove_column :users, :sms_ending_at
    remove_column :users, :sms_starting_at
  end
end
