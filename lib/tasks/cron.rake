desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Booking.charge_booking_fee
end