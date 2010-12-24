class TwitterWrapper
  def initialize(user)
    @config = YAML::load_file(File.join(Rails.root, 'config', 'twitter.yml'))[Rails.env]
    @user = user
  end
  
  def oauth
    unless @oauth
      options = {:api_endpoint => "http://api.twitter.com", :signing_endpoint => "http://api.twitter.com"}
      @oauth = Twitter::OAuth.new(@config['consumer_key'], @config['consumer_secret'], options)
      @oauth.set_callback_url(@config['callback_url'])
    end
    @oauth
  end
  
  def request_token
    oauth.request_token
  end
 
  def authorize_url
    request_token.authorize_url
  end
 
  def get_access_token(token, secret, verifier)
    oauth.authorize_from_request(token, secret, verifier)
    
    @user.twitter_token, @user.twitter_secret = oauth.access_token.token, oauth.access_token.secret
    twitter = Twitter::Base.new oauth
    @user.twitter_name = twitter.verify_credentials[:screen_name]
    @user.save(:validation => false)
  end
  
  def twitter
    oauth.authorize_from_access(*client_token_and_secret)
    @twitter ||= Twitter::Base.new oauth
  end
  
  # post to application twitter if @user is :here_stay
  def client_token_and_secret
    if @user.is_a?(Symbol) && @user == :here_stay 
      [@config['oauth_token'], @config['oauth_token_secret']]
    elsif @user.is_a?(User)
      [@user.twitter_token, @user.twitter_secret]
    else
      raise ArgumentError, 'Invalid user. Use :here_stay or an instance of the class User'
    end
  end
  
  def post(message)
    twitter.update(message)
  end
  
  
  # append shorten url to message and update twitter statuses
  def post_with_url(message, url = nil)
    message << " #{BitlyWrapper.short_url(url)}" if url.present?
    post(message)
  end
  
  def self.delayed_post(user, message, url)
    Delayed::Job.enqueue(TweeterUpdater.new(user, message, url))
  end
  
  #
  # post statuses to twitter without url to unit
  #
  def self.post_unit_added(unit)
    message = "#{ActionController::Base.helpers.truncate(unit.name, :length => 50)} has been added. #{unit.price_from}"
    TwitterWrapper.delayed_post(:here_stay, message, unit.fb_url)
    if unit.user and unit.user.post_twitter_updates?
      message = "#{ActionController::Base.helpers.truncate(unit.name, :length => 50)} has been added for rent. #{unit.price_from}"
      TwitterWrapper.delayed_post(unit.user.id, message, unit.fb_url)
    end
  end
  
  def self.post_unit_rented(booking)
    message = "#{ActionController::Base.helpers.truncate(booking.rental_unit.name, :length => 50)} has been rented from #{booking.start_date.to_s(:short_date)} to #{booking.stop_date.to_s(:short_date)}"
    TwitterWrapper.delayed_post(:here_stay, message, booking.rental_unit.fb_url)
    if booking.rental_unit.user and booking.rental_unit.user.post_twitter_updates?
      TwitterWrapper.delayed_post(booking.rental_unit.user.id, message, booking.rental_unit.fb_url)
    end
  end
  
  def self.post_auction_added(auction)
    message = "Auction #{ActionController::Base.helpers.truncate(auction.title, :length => 50)} has been added."
    TwitterWrapper.delayed_post(:here_stay, message, auction.fb_url)
    if auction.user and auction.user.post_twitter_updates?
      TwitterWrapper.delayed_post(auction.user.id, message, auction.fb_url)
    end
  end
end
