class CreateFunds < ActiveRecord::Migration
  def self.up
    create_table :funds do |t|
      t.string :type
      t.string :state
      
      t.integer :user_id
      t.integer :document_id
      t.string :document_type
      t.integer :cents, :null => false, :default => 0
      t.string :transaction_id
      t.text :description
      t.datetime :processed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :funds
  end
end
