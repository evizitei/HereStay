module ApplicationHelper
  def fb_login_button
    url = request.url  =~ /mobile/ ? request.url : "http://apps.facebook.com/#{Facebook::APP_NAME}/"
    "<fb:login-button onlogin=\"window.top.location.href='#{url}'\"  perms=\"publish_stream,offline_access,user_birthday,email,user_location\"></fb:login-button>".html_safe
  end
  
  def fb_mobile_login_button
    "<fb:login-button onlogin=\"window.top.location.href='#{controller.request.uri}'\"  perms=\"publish_stream,offline_access,user_birthday,email,user_location\"></fb:login-button>".html_safe
  end
  
  def fb_connect_async_js
    if Rails.env.production? || Rails.env.development?
      js = <<-JAVASCRIPT
        window.fbAsyncInit = function() {
          FB.init({appId: '#{Facebook::APP_ID}', status: true, cookie: true,xfbml: true});
          FB.Canvas.setAutoResize();
        };
        (function() {
          var e = document.createElement('script'); e.async = true;
          e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
          document.getElementById('fb-root').appendChild(e);
        }());
      JAVASCRIPT
      javascript_tag(js).html_safe
    else
      ""
    end
  end
  
  def fb_button(*args, &block)
    if block_given?
      options = args.first || {}
      "<label class='fbButton #{options[:class_name]}'>#{capture(&block)}</label>".html_safe
    else
      text = args.first
      url = args.second
      options = args.third || {}
      link = link_to(url, :method => options[:method],:title=>text ,:rel => options[:rel], :class => options[:link_class], :confirm => options[:confirm]){ "<input type=button value=\"#{text}\">" }
      "<label class='fbButton #{options[:class_name]}'>#{link}</label>".html_safe
    end
  end
  
  def simple_button(*args, &block)    
    if block_given?
      options = args.first || {}
      "<label class='#{options[:class_name]} simple-button'>#{capture(&block)}</label>".html_safe
    else
      text = args.first
      url = args.second
      options = args.third || {}
      link = link_to(url, :method => options[:method],:title=>text ,:rel => options[:rel], :class => options[:link_class], :confirm => options[:confirm], :title => ''){ "<input type=button value=\"#{text}\">" }
      "<label class='#{options[:class_name]} simple-button #{current_page?(url) ? 'current' : ''}'>#{link}</label>".html_safe
    end
  end
    
  def get_flash_message
    if flash[:alert]
      wrap_flash_message flash[:alert], :alert
    elsif flash[:notice]
      wrap_flash_message flash[:notice], :notice
    end
  end

  def wrap_flash_message(msg, flash_type)
    content_tag(:div, msg, :class => "flash #{flash_type}")
  end

  def display_flashes(msg = nil, flash_type = nil)
    msg = msg.present? ? wrap_flash_message(msg, flash_type) : get_flash_message
    content_tag(:div, :id => 'flash') do
      content_tag(:div, msg, :class => 'wrapper')
    end
  end
  
  def show_date(date, format = :long)
    date.to_date.to_s(format)
  end
  
  def enable_jqueryui_datepicker(selector=".date_picker")
    "<script type=\"text/javascript\">
      $(function(){
        $('#{selector}').datepicker({changeMonth: true, 
                                          changeYear: true,
                                          showButtonPanel: true,
                                          dateFormat: 'mm/dd/yy',
                                          yearRange: '-20:+3'});
      });
      </script>"
  end
  
  def date_picker_tag(name,date,options={})
    value = date.nil? ? "" : date.strftime("%m/%d/%Y")
    options[:class] = (options[:class].nil?) ? "date_picker" : "#{options[:class]} date_picker"
    options[:style] = "width:8em" if options[:style].nil?
    return text_field_tag(name,value,options)
  end
  
  # build exteranl link to the facebook app with redirect path
  # should be used for publishing application pages on the external sites
  def fb_url(options)
    url = url_for(options)
    "http://apps.facebook.com/#{fb_app_name}/?redirect_to=#{Rack::Utils.escape(url)}"
  end
  
  def slider_labels(min, max, val1, val2)
    labels = ''
    min.upto(max) do |i|
      selected = (i >= val1.to_i && i <= val2.to_i)
      labels += "<div class ='l#{i} #{'sel' if selected}'>#{i}#{'+' if i >= 5}</div>"
    end
    labels.html_safe
  end
  
  def slider_ratings(val1, val2)
    labels = ''
    1.upto(10) do |i|
      selected = (i >= val1.to_i && i <= val2.to_i)
      labels += "<div class ='l#{i} #{i%2 == 0 ? 'odd' : 'even'} #{'sel' if selected}'></div>"
    end
    labels.html_safe
  end
  
  def zoom_labels(par)
    values = ['', '1.5', '5', '25', '90', '350' ]
    values[par.to_i]
  end
  
  def belongs_to_friend_icon user, rental_unit
    if user && !user.fb_friend_ids.blank? && !rental_unit.user.fb_friend_ids.blank?
      if rental_unit.user.fb_friend_ids.include?(user.fb_user_id.to_i)
        link_to image_tag('icon_friend.png', :title => 'The listing belongs to your friend.', :border => 0), relation_path(rental_unit.user), :class => 'clueTip', :rel => relation_path(rental_unit.user)
      elsif !rental_unit.is_owner?(user) && !(user.fb_friend_ids & rental_unit.user.fb_friend_ids).blank?
        link_to image_tag('icon_friend_of_friend.png', :title => 'The listing belongs to the friend of your friend.', :border => 0), relation_path(rental_unit.user), :class => 'clueTip', :rel => relation_path(rental_unit.user)
      end
    end
  end
  
  def gmap_latlng(lat,lng)
    if !lat.blank? && !lng.blank?
      latlng = "#{lat}, #{lng}"
    elsif logged_in? && current_user.get_latlng
      latlng = "#{current_user.fb_lat}, #{current_user.fb_lng}"
    else  
      latlng = "39.828175, -98.579500"
    end   
    latlng
  end
  
  def gmap_zoom(zoom = nil)
    return zoom unless zoom.blank?
    zoom = logged_in? && current_user.valid_country? && current_user.get_latlng? ? 6 : 3
  end
  
  def gmap_markers(items, prefix = '', center = true)
    if params[:advanced] == '1'
      rows = []
      if center && !params[:location_lat].blank? && !params[:location_lng].blank?
        rows << "marker = new google.maps.Marker({position: latlng, map: #{prefix}map, title: 'center'}); markersArray.push(marker);"
      end
      items.each do |item|
        if !item.lng.blank? && !item.lat.blank?
          rows << "latlng = new google.maps.LatLng(#{item.lat}, #{item.lng});"
          rows << "marker = new google.maps.Marker({position: latlng, map: #{prefix}map , title: '#{item.name}'}); markersArray.push(marker);"
        end
      end
      rows.join(' ').html_safe
    end
  end
  
  def fb_profile_pic(options)
    options[:linked] = 'false'
    content_tag(:a, :href => "http://www.facebook.com/profile.php?id=#{options[:uid]}", :target => 'top', :class => 'fb-profile-link') do
      content_tag 'fb:profile-pic','', options
    end
  end
  
  def fb_name(options)
    options[:linked] = 'false'
    content_tag(:a, :href => "http://www.facebook.com/profile.php?id=#{options[:uid]}", :target => 'top', :class => 'fb-profile-link') do
      content_tag 'fb:name', '', options
    end
  end
  
  def rental_unit_availabilities(rental_unit)
    row = "{title: 'Not available', end: new Date('#{Time.now.strftime("%m/%d/%Y")}')}#{',' if rental_unit.reservations.size > 0}"
    rental_unit.bookings.active.includes(:reservation).each_with_index do |booking, i|
      if reservation = booking.reservation
        start_at = (i == 0 && reservation.start_at.to_date <= Time.now.to_date) ? Time.now.to_date + 1.day : reservation.start_at
        row += "{title: 'Not available', start: new Date('#{start_at.strftime("%m/%d/%Y")}'), end: new Date('#{reservation.end_at.strftime("%m/%d/%Y")}')}#{',' if (i+1) < (rental_unit.reservations.size)}"
      end
    end
    row
  end
  
  def user_online_status(user)
    if user
      return image_tag('user_online.png', :title => 'User online') if user.online?
      return "(available by phone)" if user.available_by_phone?
      image_tag('user_offline.png', :title => 'User offline')
    end    
  end
  
  def action?(action)
    controller.action_name == action
  end
  
  def confirmed_bookings_count(rental_unit = nil)
    if rental_unit
      rental_unit.bookings.active.confirmed.size
    else
      Booking.for_user(current_user).active.confirmed.size
    end
  end

  def advanced_search_path
    if ['lots', 'bids'].include?(controller_name)
      search_auction_lots_path
    else
      search_rental_units_path
    end
  end
  
  def li_link_to(*args)
    text = args.first
    url = args.second
    options = args.third || {}
    content_tag(:li, :class =>"#{options[:class]} #{current_page?(url) ? 'current' : ''}") do
      link_to text, url
    end
  end
  
  def property_bread_crumbs(crumbs, step = 1)
    content_for :bread_crumbs do
      content_tag(:div, :class => 'bread_crumbs') do
        crumbs.each_with_index do |crumb, i|
          #instead 'join' method  to get separator in selected crumbs
          crumb = crumb + ' > ' if crumbs.size > 1 && crumbs.size > i+1
          concat content_tag(:span, crumb, :class => (step > i ? 'selected' : ''))
        end
      end
    end
  end
end
