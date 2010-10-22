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
      btn = "<input type=button value=\"#{text}\">"
      "<label class='fbButton #{options[:class_name]}'><a href='#{url}'>#{btn}</a></label>".html_safe
    end
  end
end
