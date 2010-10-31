class AddPrimaryToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :primary, :boolean, :default => false
  end

  def self.down
    remove_column :photos, :primary
  end
end
