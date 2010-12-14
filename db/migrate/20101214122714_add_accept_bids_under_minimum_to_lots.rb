class AddAcceptBidsUnderMinimumToLots < ActiveRecord::Migration
  def self.up
    add_column :lots, :accept_bids_under_minimum_to_lots, :boolean, :default => 0, :null => false
  end

  def self.down
    remove_column :lots, :accept_bids_under_minimum_to_lots
  end
end
