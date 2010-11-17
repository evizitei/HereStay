Given /^it currently is "([^"]*)"$/ do |time|
  Timecop.travel(Time.parse(time))
end

Then /^return to the present$/ do
  Timecop.return
end
