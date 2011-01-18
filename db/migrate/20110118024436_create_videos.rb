class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.integer :rental_unit_id
      t.string :status
      t.string :youtube_id
      t.string :error
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
  end
end
