if Rails.env.production?
  ActionMailer::Base.smtp_settings = {  
    :address              => "herestay.com",
    :port                 => 25,
    :domain               => "herestay.com" 
  }
end

ActionMailer::Base.default_url_options[:host] = "herestay.com"  