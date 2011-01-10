class AddWinningToBids < ActiveRecord::Migration
  def self.up
    add_column :bids, :winning, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :bids, :winning
  end
end
