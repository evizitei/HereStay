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
end