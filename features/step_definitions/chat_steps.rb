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

When /^the owner of booking "([^"]*)" posts the message "([^"]*)"$/ do |booking_id, message|
  booking = Booking.find(booking_id)
  owner = User.find_by_fb_user_id(booking.owner_fb_id)
  BookingMessage.create(:user_fb_id=>owner.fb_user_id,:booking_id=>booking.id,:message=>message)
end

When /^I wait (\d+) seconds$/ do |seconds|
  sleep(seconds.to_i)
end

Given /^There is a booking discussion with id "([^"]*)" where I am the renter$/ do |booking_id|
  owner = Factory(:user,:fb_user_id=>"98765")
  unit = Factory(:rental_unit,:user=>owner)
  booking = Factory(:booking,:owner_fb_id=>owner.fb_user_id,
                    :rental_unit=>unit,:id=>booking_id,:renter_fb_id => @user.fb_user_id)
end

Then /^booking (\d+) should have (\d+) messages$/ do |booking_id,count|
  booking = Booking.find(booking_id)
  booking.booking_messages.size.should == count.to_i
end

