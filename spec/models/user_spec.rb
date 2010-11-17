require 'spec_helper'

describe User do
  let(:built_user){ Factory(:user)}
  
  it "defaults the last poll time at creation" do
    built_user.last_poll_time.should_not == nil
  end
  
  it "defaults the starting contact time to 7 AM" do
    built_user.sms_starting_at.strftime("%H:%M").should == "07:00"
  end
  
  it "defaults the stop contact time to 9 PM" do
    built_user.sms_ending_at.strftime("%H:%M").should == "21:00"
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
  
  describe "available by phone" do
    let(:user){ User.new(:phone=>"15732395840") }
    
    it "fails if the user has no phone" do
      no_phone_user = User.new
      no_phone_user.available_by_phone?.should == false
    end
  
    it "fails if time is earlier than range" do
      Timecop.travel(Time.parse("01:00 AM"))
      local_user = user
      local_user.update_attributes!(:phone=>"15732395840")
      local_user.available_by_phone?.should == false
      Timecop.return
    end
    
    it "fails if time is later than range" do
      Timecop.travel(Time.parse("11:00 PM"))
      local_user = user
      local_user.update_attributes!(:phone=>"15732395840")
      local_user.available_by_phone?.should == false
      Timecop.return
    end
    
    it "succeeds if time is inside range" do
      Timecop.travel(Time.parse("11:00 AM"))
      local_user = user
      local_user.update_attributes!(:phone=>"15732395840")
      local_user.available_by_phone?.should == true
      Timecop.return
    end
  end
  
  describe "availability message" do
    let(:user){ User.new(:phone=>"15732395840") }
    
    it "is online if last pulse just happened" do
      user.pulse!
      user.availability_message.should == "online!"
    end
    
    it "is offline if last pulse was hours ago happened" do
      user.update_attributes!(:phone=>nil,:last_poll_time=>8.hours.ago)
      user.availability_message.should == "offline."
    end
    
    it "is available by phone if inside the timerange, and there is a phone" do
      Timecop.travel(Time.parse("4:00 AM"))
      user.update_attributes!(:last_poll_time=>8.hours.ago,:phone=>"15732395840")
      user.availability_message.should == "available by phone."
      Timecop.return
    end
  end
end
