Given /^there is a unit named "([^"]*)" with owner "([^"]*)"$/ do |unit_name, user_fb_id|
  user = User.find_or_create_by_fb_user_id(user_fb_id)
  Factory(:rental_unit,:user=>user,:name=>unit_name)
end