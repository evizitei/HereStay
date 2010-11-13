Micasasucasa::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.serve_static_assets = true
  config.i18n.fallbacks = true
  config.action_mailer.default_url_options = { :host => "herestay.heroku.com" }
  config.after_initialize do
    Moonshado::Sms.configure do |config|
      config.api_key = ENV['MOONSHADOSMS_URL']
    end
  end
end
