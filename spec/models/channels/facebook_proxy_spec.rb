require 'spec_helper'

describe FacebookProxy do
  describe "Property rented" do
    before do
      @user = Factory(:user, :authorize_signature => '12345')
      @user.stubs("post_fb_wall_updates?").returns(true)
      @rental_unit = Factory(:rental_unit, :user => @user)
      @booking = Factory(:booking, :rental_unit => @rental_unit)
    end
    
    it "should post to application's FB wall and user's FB walls" do
      @user.stubs("post_fb_wall_updates?").returns(true)
      FacebookProxy.expects(:new).once.with(:here_stay).returns(mock(:put_object => :true))
      FacebookProxy.expects(:new).once.with(@user.authorize_signature).returns(mock(:put_object => :true))
      FacebookProxy.post_unit_rented(@booking)
    end
    
    it "should post to application's FB wall and not post user's FB walls" do
      @user.stubs("post_fb_wall_updates?").returns(false)
      FacebookProxy.expects(:new).once.with(:here_stay).returns(mock(:put_object => :true))
      FacebookProxy.expects(:new).never.with(@user.authorize_signature)
      FacebookProxy.post_unit_rented(@booking)
    end
  end
end