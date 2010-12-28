Moonshado::Sms.configure do |config|
  if ['test', 'development'].include?(Rails.env)
    config.production_environment = false
  elsif ENV['MOONSHADOSMS_URL']
    config.api_key = ENV['MOONSHADOSMS_URL']
  elsif File.exists?("#{Rails.root}/config/moonshado.conf")
    config.api_key = File.read("#{Rails.root}/config/moonshado.conf")
  end
end