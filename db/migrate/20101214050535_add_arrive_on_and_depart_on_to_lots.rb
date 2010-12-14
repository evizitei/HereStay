class AddArriveOnAndDepartOnToLots < ActiveRecord::Migration
  def self.up
    add_column :lots, :arrive_on, :date
    add_column :lots, :depart_on, :date
  end

  def self.down
    remove_column :lots, :depart_on
    remove_column :lots, :arrive_on
  end
end
