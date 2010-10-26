class AddRewardsRedeemedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :redeemed_rewards, :float
  end

  def self.down
    remove_column :users, :redeemed_rewards
  end
end
