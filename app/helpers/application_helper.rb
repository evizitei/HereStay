module ApplicationHelper
  def fb_login_button
    "<fb:login-button onlogin=\"window.top.location.href='http://apps.facebook.com/#{Facebook::APP_NAME}/'\"  perms=\"publish_stream,offline_access,user_birthday,email\"></fb:login-button>".html_safe
  end
  
  def fb_connect_async_js
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
  end
  
  def fb_button(*args, &block)
    if block_given?
      options = args.first || {}
      "<label class='fbButton #{options[:class_name]}'>#{capture(&block)}</label>".html_safe
    else
      text = args.first
      url = args.second
      options = args.third || {}
      link = link_to(url, :method => options[:method] ){ "<input type=button value=\"#{text}\">" }
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
end
