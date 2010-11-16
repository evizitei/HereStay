Given /^I am the user with FB id "([^"]*)"$/ do |fb_id|
  @user = User.find_or_create_by_fb_user_id(fb_id)
end

Then /^my phone number should be "([^"]*)"$/ do |phone|
  @user.phone.should == phone
end