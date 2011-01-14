namespace :utils do
  desc "Make primary photo for each listing."
  task :make_primary_photo => :environment do
    RentalUnit.all.each do |u|
      unless u.photos.primary.exists?
        photo = u.photos.first and photo.primary!
      end
    end
  end
  
  desc "Charge booking fee. Should be run once a day"
  task :charge_booking_fee => :environment do
    Booking.charge_booking_fee
  end
  
  desc "Finish expired auctions. Should be run every 15 minutes"
  task :finish_auctions => :environment do
    Lot.finish!
  end
  
  desc "Remove old unlinked photos. Should be run once a day"
  task :remove_unlinked_images => :environment do
    Photo.unlinked.where("created_at < ?", 1.days.ago).map(&:destroy)
  end
end