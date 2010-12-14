class RenameLotColumn < ActiveRecord::Migration
  def self.up
    rename_column :lots, :accept_bids_under_minimum_to_lots, :accept_bids_under_minimum
  end

  def self.down
    rename_column :lots, :accept_bids_under_minimum, :accept_bids_under_minimum_to_lots
  end
end
