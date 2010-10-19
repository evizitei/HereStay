class IndexRentalUnitsByFacebookId < ActiveRecord::Migration
  def self.up
    add_index :rental_units,:fb_user_id
  end

  def self.down
    remove_index :rental_units,:fb_user_id
  end
end
