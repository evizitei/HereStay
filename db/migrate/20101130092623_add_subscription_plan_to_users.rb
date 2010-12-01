class AddSubscriptionPlanToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_plan, :string
  end

  def self.down
    remove_column :users, :subscription_plan
  end
end
