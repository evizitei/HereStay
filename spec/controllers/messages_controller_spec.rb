require 'spec_helper'

describe MessagesController do
  describe "Chat polling" do

    before(:each) do
      owner = Factory(:user,:fb_user_id=>"12345")
      unit = Factory(:rental_unit,:user_id=>owner.id)
      @booking = Factory(:booking,:rental_unit=>unit)
      @messages = []
      3.times{ @messages << Factory(:booking_message,:user_fb_id=>owner.fb_user_id,:booking=>@booking)}
      @user = Factory(:user,:fb_user_id=>"54321")
    end

    it "loads the correct booking" do
      get(:poll_chat,:user=>@user.fb_user_id,:booking=>@booking.id,
          :last_message=>nil)
      assigns(:booking).should == @booking
    end

    it "loads the correct user" do
      get(:poll_chat,:user=>@user.fb_user_id,:booking=>@booking.id,
          :last_message=>nil)
      assigns(:user).should == @user
    end

    it "finds all messages if last message is nil" do
      get(:poll_chat,:user=>@user.fb_user_id,:booking=>@booking.id,
          :last_message=>nil)
      assigns(:list).size.should == @messages.size
    end

    it "finds all messages if last message is blank" do
      get(:poll_chat,:user=>@user.fb_user_id,:booking=>@booking.id,
          :last_message=>"")
      assigns(:list).size.should == @messages.size
    end
  end
end
