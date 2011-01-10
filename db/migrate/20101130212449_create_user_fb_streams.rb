class CreateUserFbStreams < ActiveRecord::Migration
  def self.up
    create_table :user_fb_streams do |t|
      t.integer :user_id
      t.integer :rental_unit_id
      t.text    :message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :user_fb_streams
  end
end
