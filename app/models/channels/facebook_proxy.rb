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
  
  # Post to wall message "(This property) has been rented from (date) to (date)"
  # when the owner confirms or creates a booking
  # TODO: move to background work
  def self.post_unit_rented(booking)
    rental_unit = booking.rental_unit
    text = "#{rental_unit.name} has been rented from #{booking.start_date.to_s(:short_date)} to #{booking.stop_date.to_s(:short_date)}"
    options = {
      :message => text,
      :link => rental_unit.fb_url,
      :name => 'view this property'
    }
p rental_unit.picture(:medium)
    options[:picture] = rental_unit.picture(:medium) if rental_unit.picture(:medium)
    FacebookProxy.new(:here_stay).put_object(:here_stay, "feed", options)
    if rental_unit.user.post_fb_wall_updates?
      FacebookProxy.new(rental_unit.user.access_token).put_object('me', "feed", options)
    end
  end
end