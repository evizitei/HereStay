class AddCompletedToLots < ActiveRecord::Migration
  def self.up
    add_column :lots, :completed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :lots, :completed
  end
end
