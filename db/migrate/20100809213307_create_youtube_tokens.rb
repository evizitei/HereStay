class CreateYoutubeTokens < ActiveRecord::Migration
  def self.up
    create_table :youtube_tokens do |t|
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :youtube_tokens
  end
end
