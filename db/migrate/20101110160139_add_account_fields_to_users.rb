class AddAccountFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :middle_initial, :string
    add_column :users, :last_name, :string
    add_column :users, :company, :string
    add_column :users, :use_fb_profile, :boolean, :default => false
  end

  def self.down
    remove_column :users, :use_fb_profile
    remove_column :users, :company
    remove_column :users, :last_name
    remove_column :users, :middle_initial
    remove_column :users, :first_name
  end
end
