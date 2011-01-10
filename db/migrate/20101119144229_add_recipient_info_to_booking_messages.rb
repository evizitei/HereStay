class AddRecipientInfoToBookingMessages < ActiveRecord::Migration
  def self.up
    add_column :booking_messages, :recipient_id, :integer
  end

  def self.down
    remove_column :booking_messages, :recipient_id
  end
end
