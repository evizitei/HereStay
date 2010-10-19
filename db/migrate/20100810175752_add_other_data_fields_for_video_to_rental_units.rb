class AddOtherDataFieldsForVideoToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :video_id, :string
    add_column :rental_units, :video_code, :string
    add_column :rental_units, :video_status, :string
  end

  def self.down
    remove_column :rental_units, :video_status
    remove_column :rental_units, :video_code
    remove_column :rental_units, :video_id
  end
end
