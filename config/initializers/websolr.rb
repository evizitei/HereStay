if ENV['WEBSOLR_URL']
  Sunspot.config.solr.url = ENV['WEBSOLR_URL']
# elsif File.exists?("#{Rails.root}/config/websolr.conf")
#   Sunspot.config.solr.url = File.read("#{Rails.root}/config/websolr.conf")
end