class ChangeUseFbProfileField < ActiveRecord::Migration
  def self.up
    change_column :users, :use_fb_profile, :boolean, :default => true
  end

  def self.down
    change_column :users, :use_fb_profile, :boolean, :default => false
  end
end
