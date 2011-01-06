if Rails.env.production?
  ActionMailer::Base.smtp_settings = {  
    :address              => "localhost",
    :port                 => 25,
    :domain               => "herestay.com" 
  }
end

if Rails.env.development? && ENV['DEV_URL']
  ActionMailer::Base.default_url_options[:host] = ENV['DEV_URL']
  HOST = ENV['DEV_URL']
else
  ActionMailer::Base.default_url_options[:host] = "herestay.com"
  HOST = "herestay.com"
end