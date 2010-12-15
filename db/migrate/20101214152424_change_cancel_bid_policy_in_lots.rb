class ChangeCancelBidPolicyInLots < ActiveRecord::Migration
  def self.up
    remove_column :lots, :cancel_bid_policy
    add_column :lots, :cancel_bid_policy, :text
  end

  def self.down
    remove_column :lots, :cancel_bid_policy
    add_column :lots, :cancel_bid_policy, :integer
  end
end
