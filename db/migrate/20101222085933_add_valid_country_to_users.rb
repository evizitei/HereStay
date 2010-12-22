class AddValidCountryToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :valid_country, :boolean, :default => false
    
    User.all.each do |user|
      if user.get_latlng? && res = GoogleApi.geocoder(user.fb_location)
        user.update_attribute(:valid_country, true) if res[:geocoded_address] =~ /USA/
      end
    end
  end

  def self.down
    remove_column :users, :valid_country
  end
end
