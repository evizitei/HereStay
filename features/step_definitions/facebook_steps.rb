Given /^I am logged in as the user with FB id "([^"]*)"$/ do |fb_id|
  @user = User.find_or_create_by_fb_user_id(fb_id)
  oauth = Object.new
  oauth.stubs(:get_user_info_from_cookie)
  Koala::Facebook::OAuth.stubs(:new).returns(oauth) 
  User.stubs(:for).returns(@user)
end
