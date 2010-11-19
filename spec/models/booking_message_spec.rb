require 'spec_helper'

describe BookingMessage do
  
  it "can track the recipient user id" do
    user = Factory(:user)
    BookingMessage.new(:recipient_id=>user.id).recipient.should == user  
  end
end
