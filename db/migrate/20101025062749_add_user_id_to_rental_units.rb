class AddUserIdToRentalUnits < ActiveRecord::Migration
  def self.up
    add_column :rental_units, :user_id, :integer
    RentalUnit.all.each do |u|
      # use update_all to avoid callbacks
      RentalUnit.update_all({:user_id =>  User.find_by_fb_user_id(u.fb_user_id).try(:id)}, {:id => u.id})
    end
  end

  def self.down
    remove_column :rental_units, :user_id
  end
end
