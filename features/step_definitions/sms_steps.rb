When /^the sms message "([^"]*)" is sent to "([^"]*)"$/ do |number, message|
  Moonshado::Sms.new(message,number).deliver_sms
end

Then /^there should be an SMS sent to "([^"]*)" saying "([^"]*)"$/ do |number, sms_text|
  messages = Moonshado::Sms.sent_messages
  messages = Moonshado::Sms.sent_messages.select{|data| 
    data[:sms][:device_address] == number and data[:sms][:message] == sms_text
  }
  messages.size.should == 1
  messages.each{|msg| Moonshado::Sms.sent_messages.delete(msg)}
end

Then /^there should be no SMS messages sent$/ do 
  if Moonshado::Sms.sent_messages
    Moonshado::Sms.sent_messages.size.should == 0
  end
end

Then /^there should be an SMS sent to "([^"]*)" containing "([^"]*)"$/ do |number, sms_text|
  messages = Moonshado::Sms.sent_messages
  messages = Moonshado::Sms.sent_messages.select{|data| 
    data[:sms][:device_address] == number and !(data[:sms][:message].index(sms_text).nil?)
  }
  messages.size.should == 1
  messages.each{|msg| Moonshado::Sms.sent_messages.delete(msg)}
end

Then /^I should be available by phone at "([^"]*)"$/ do |time|
  time = Time.parse(time)
  Timecop.travel(time)
  @user.available_by_phone?.should == true
  Timecop.return
end

Then /^I should not be available by phone at "([^"]*)"$/ do |time|
  time = Time.parse(time)
  Timecop.travel(time)
  @user.available_by_phone?.should == false
  Timecop.return
end
