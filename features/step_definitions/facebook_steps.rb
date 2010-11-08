Given /^I am logged in as the user with FB id "([^"]*)"$/ do |fb_id|
  @user = User.find_or_create_by_fb_user_id(fb_id)
  oauth = Object.new
  oauth.stubs(:get_user_info_from_cookie)
  Koala::Facebook::OAuth.stubs(:new).returns(oauth) 
  User.stubs(:for).returns(@user)
end

Given /^There is a booking discussion with id "([^"]*)" where I am the renter$/ do |booking_id|
  owner = Factory(:user,:fb_user_id=>"98765")
  unit = Factory(:rental_unit,:user=>owner)
  booking = Factory(:booking,:rental_unit=>unit,:id=>booking_id,:renter_fb_id => @user.fb_user_id)
end

