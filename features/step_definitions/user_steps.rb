Given /^I am the user with FB id "([^"]*)"$/ do |fb_id|
  @user = User.find_or_create_by_fb_user_id(fb_id)
end

Given /^the user "([^"]*)" has the phone number "([^"]*)"$/ do |fb_id, phone|
  User.find_by_fb_user_id(fb_id).update_attributes!(:phone=>phone)
end


Then /^my phone number should be "([^"]*)"$/ do |phone|
  @user.phone.should == phone
end

Given /^the user "([^"]*)" should not be online$/ do |fb_id|
  User.find_by_fb_user_id(fb_id).online?.should == false
end

Given /^the user "([^"]*)" should be available by phone$/ do |fb_id|
  user = User.find_by_fb_user_id(fb_id)
  user.phone.blank?.should == false
  user.available_by_phone?.should == true
end
