class AddImageRemoteUrlToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :image_remote_url, :string
  end

  def self.down
    remove_column :photos, :image_remote_url
  end
end
