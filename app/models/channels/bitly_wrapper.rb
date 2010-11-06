class BitlyWrapper  
  def self.short_url(url)
    config = YAML::load_file(File.join(Rails.root, 'config', 'bitly.yml'))
    Bitly.use_api_version_3
    bitly = Bitly.new(config['user_name'], config['api_key'])
    u = bitly.shorten(url)
    u.short_url
  end
end