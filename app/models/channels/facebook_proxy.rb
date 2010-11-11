class FacebookProxy
  def initialize(access_token)
    @access_token = if access_token === :here_stay
      oauth = FacebookProxy.oauth
      oauth.get_app_access_token
    else
      access_token
    end
  end
  
  def graph
    @graph ||= Koala::Facebook::GraphAPI.new(@access_token)
  end
  
  def self.oauth
    Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s)
  end
  
  def self.get_user_info_from_cookie(cookies)
    oauth = FacebookProxy.oauth
    oauth.get_user_info_from_cookie(cookies)
  end
  
  def get_object(*args)
    graph.get_object(*args)
  end
  
  def get_connections(*args)
    graph.get_connections(*args)
  end
  
  def put_object(target, *args)
    target = Facebook::APP_ID.to_s if target === :here_stay
    graph.put_object(target, *args)
  end
end