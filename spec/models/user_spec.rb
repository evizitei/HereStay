require 'spec_helper'

describe User do
  let(:built_user){ Factory(:user)}
  
  it "defaults the last poll time at creation" do
    built_user.last_poll_time.should_not == nil
  end
  
  it "can check in to update last poll time anytime" do
    old_time = 1.week.ago
    user = User.create!(:last_poll_time=>old_time)
    user.pulse!
    user.reload.last_poll_time.should_not == old_time
  end
  
  it "has a phone number" do
    user = built_user
    user.update_attributes!(:phone=>"5732395840")
    user.phone.should == "5732395840"
  end
  
  it "is online if last poll was very recent" do
    user = built_user
    user.pulse!
    user.should be_online
  end
  
  it "is offline if last poll was older than 1 minute" do
    user = built_user
    user.update_attributes!(:last_poll_time=>2.minutes.ago)
    user.should_not be_online
  end
end
