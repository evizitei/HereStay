namespace :utils do
  desc "Make primary photo for each listing."
  task :make_primary_photo => :environment do
    RentalUnit.all.each do |u|
      unless u.photos.primary.exists?
        photo = u.photos.first and photo.primary!
      end
    end
  end
end