require 'spec_helper'

describe Bid do
  before do
    Lot.any_instance.stubs(:run_created_callbacks)
    @lot = Lot.create({
      :title => 'Auction title', :start_at => Time.zone.now,
      :end_at => 2.days.from_now, :terms => 'Terms and conditions',
      :property_id => 1, :min_bid_cents => 3000
    })
  end
  
  it "should create a bid" do
    Bid.any_instance.stubs(:creation_notification)
    @lot.bids.create!(:cents => 3000, :user_id => 2)
  end
  
  it "should not create if bid is less than lot's min bid" do
    Bid.any_instance.stubs(:creation_notification)
    bid = @lot.bids.build(:cents => 2900, :user_id => 2)
    bid.valid?.should be_false
  end
  
  it "should create if the bid is less than lot's accept_bids_under_minimum_to_lots is true" do
    Bid.any_instance.stubs(:creation_notification)
    @lot.update_attribute(:accept_bids_under_minimum_to_lots, true)
    bid = @lot.bids.build(:cents => 2900, :user_id => 2)
    bid.valid?.should be_true
  end
  
  it "should not create if the bid is less than the next lot bid" do
    Bid.any_instance.stubs(:creation_notification)
    @lot.bids.create!(:cents => 3000, :user_id => 2)
    bid = @lot.bids.build(:cents => 3000, :user_id => 2)
    bid.valid?.should be_false
  end
  
  it "should create if the bid is greater than the next lot bid" do
    Bid.any_instance.stubs(:creation_notification)
    @lot.bids.create!(:cents => 3000, :user_id => 2)
    bid = @lot.bids.build(:cents => 4000, :user_id => 2)
    bid.valid?.should be_true
  end
  
  it "should send notification to owner and renter" do
    AuctionMailer.expects(:bid_created_to_owner).returns(mock(:deliver => :true))
    AuctionMailer.expects(:bid_created_to_renter).returns(mock(:deliver => :true))
    @lot.bids.create!(:cents => 4000, :user_id => 2)
  end
end
