namespace :utils do
  desc "Make primary photo for each listing."
  task :make_primary_photo => :environment do
    RentalUnit.all.each do |u|
      unless u.photos.primary.exists?
        photo = u.photos.first and photo.primary!
      end
    end
  end
  
  desc "Charge booking fee."
  task :charge_booking_fee => :environment do
    Booking.charge_booking_fee
  end
end