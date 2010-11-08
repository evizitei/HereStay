Given /^I am the user with FB id "([^"]*)"$/ do |fb_id|
  @user = User.find_or_create_by_fb_user_id(fb_id)
end

Given /^There is a booking discussion with id "([^"]*)"$/ do |booking_id|
  @booking = Booking.find_or_create_by_id(booking_id)
end

When /^FB User "([^"]*)" posts "([^"]*)" to the chat for booking "([^"]*)"$/ do |fb_id, message, booking_id|
  post("/chat_post", xml_result, {"CONTENT_TYPE" => "text/json"})
end

Then /^there should be a new chat saying "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should get a JSON chat back saying "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

