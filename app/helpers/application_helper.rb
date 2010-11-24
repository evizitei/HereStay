module ApplicationHelper
  def fb_login_button
    "<fb:login-button onlogin=\"window.top.location.href='http://apps.facebook.com/#{Facebook::APP_NAME}/'\"  perms=\"publish_stream,offline_access,user_birthday,email,user_location\"></fb:login-button>".html_safe
  end
  
  def fb_connect_async_js
    if Rails.env.production? || Rails.env.development?
      js = <<-JAVASCRIPT
      <script>
        window.fbAsyncInit = function() {
          FB.init({appId: '#{Facebook::APP_ID}', status: true, cookie: true,xfbml: true});
          FB.Canvas.setAutoResize();
        };
        (function() {
          var e = document.createElement('script'); e.async = true;
          e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
          document.getElementById('fb-root').appendChild(e);
        }());
      </script>
      JAVASCRIPT
      js.html_safe
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
      link = link_to(url, :method => options[:method],:title=>text ){ "<input type=button value=\"#{text}\">" }
      "<label class='fbButton #{options[:class_name]}'>#{link}</label>".html_safe
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
        link_to image_tag('icon_friend.png', :title => 'The listing belongs to your friend.', :border => 0), relation_path(rental_unit.user), :class => 'fancybox'
      elsif !rental_unit.is_owner?(user) && !(user.fb_friend_ids & rental_unit.user.fb_friend_ids).blank?
        link_to image_tag('icon_friend_of_friend.png', :title => 'The listing belongs to the friend of your friend.', :border => 0), relation_path(rental_unit.user), :class => 'fancybox'
      end
    end
  end
end
