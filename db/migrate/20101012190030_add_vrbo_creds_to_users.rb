class AddVrboCredsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :vrbo_login, :string
    add_column :users, :vrbo_password, :string
  end

  def self.down
    remove_column :users, :vrbo_password
    remove_column :users, :vrbo_login
  end
end
