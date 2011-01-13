env :MAILTO, 'dr.demax@gmail.com'
set :output, {:error => 'error.log', :standard => 'cron.log'}

every 1.day, :at => '03:00' do
  rake "utils:charge_booking_fee"
  rake "utils:remove_unlinked_images"
end

every 15.minutes do
  rake "utils:finish_auctions"
end