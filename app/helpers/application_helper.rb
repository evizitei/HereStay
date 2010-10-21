module ApplicationHelper
  def fb_login_button
    "<fb:login-button onlogin=\"window.top.location.href='http://apps.facebook.com/#{Facebook::APP_NAME}/'\"  perms=\"publish_stream,offline_access,user_birthday,email\"></fb:login-button>".html_safe
  end
  
  def fb_connect_async_js
      js = <<-JAVASCRIPT
      <script>
        window.fbAsyncInit = function() {
          FB.init({appId: '#{Facebook::APP_ID}', status: true, cookie: true,xfbml: true});

          FB.Event.subscribe('auth.sessionChange', function(response) {
            if (response.session) {
              // A user has logged in, and a new cookie has been saved
            } else {
              // The user has logged out, and the cookie has been cleared
            }
          });

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
end
