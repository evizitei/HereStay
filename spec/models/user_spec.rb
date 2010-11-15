require 'spec_helper'

describe User do
  it "defaults the last poll time at creation" do
    User.new.last_poll_time.should_not == nil
  end
  
  it "can check in to update last poll time anytime" do
    old_time = 1.week.ago
    user = User.create!(:last_poll_time=>old_time)
    user.pulse!
    user.reload.last_poll_time.should_not == old_time
  end
  
  it "has a phone number" do
    user = Factory(:user)
    user.update_attributes!(:phone=>"5732395840")
    user.reload.phone.should == "5732395840"
  end
end