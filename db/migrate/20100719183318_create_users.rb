class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.datetime :authorized_at
      t.string :fb_user_id
      t.datetime :fb_updated_at
      t.string :session_key
      t.datetime :session_expires_at
      t.string :app_api_key
      t.string :authorize_signature
      t.text :linked_account_ids

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
