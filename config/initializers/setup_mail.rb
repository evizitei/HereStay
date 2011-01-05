if Rails.env.production?
  ActionMailer::Base.smtp_settings = {  
    :address              => "localhost",
    :port                 => 25,
    :domain               => "herestay.com" 
  }
end

ActionMailer::Base.default_url_options[:host] = "herestay.com"  