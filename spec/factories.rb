Factory.define :booking do |b|
  b.renter_name "Some name"
  b.start_date "10/1/2010"
  b.stop_date "10/5/2010"
  b.description "Great Vacation"
end

Factory.define :booking_message do |b|
  
end

Factory.define :rental_unit do |r|
  r.name "My Place"
  r.description "is beautiful"
  r.address "2275 E Bearfield Sub"
  r.city "Columbia"
  r.state "MO"
  r.zip "65201"
end

Factory.define :user do |u|
  u.fb_user_id "12345"
end
