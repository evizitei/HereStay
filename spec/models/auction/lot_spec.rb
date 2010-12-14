require 'spec_helper'

describe Lot do
  before do
    @attributes = {
      :title => 'Auction title', :start_at => Time.zone.now,
      :end_at => 2.days.from_now, :terms => 'Terms and conditions',
      :property_id => 1, :min_bid_cents => 3000
    }
  end
  
  it "should create a lot" do
    lot = Lot.new(@attributes)
    lot.stubs(:run_created_callbacks)
    lot.save.should be_true
  end
  
  it "should return current bid, current bids, next bid cents" do
    lot = Lot.new(@attributes)
    lot.current_bid_cents.should == 3000
    lot.next_bid_cents.should == 3000
    lot.current_bids.should be_empty
    lot.current_bid.should be_nil
  end
  
  # it "should send a notification when lot is created" do
  #   lot = Lot.new(@attributes)
  #   AuctionMailer.expects(:lot_created).with(lot).returns(mock(:deliver => :true))
  #   lot.save!
  # end
  
  it "should allow save with zero min bid" do
    lot = Lot.new(@attributes.merge(:min_bid_cents => 0, :accept_bids_under_minimum_to_lots => true))
    lot.stubs(:run_created_callbacks)
    lot.save.should be_true
  end
  
  it "should disallow save with zero min bid" do
    lot = Lot.new(@attributes.merge(:min_bid_cents => 0, :accept_bids_under_minimum_to_lots => false))
    lot.stubs(:run_created_callbacks)
    lot.save.should be_false
  end
  
  it "should send finish notifications to onwer" do
    Lot.any_instance.stubs(:run_created_callbacks)
    lot = Lot.create!(@attributes)
    
    AuctionMailer.expects(:lot_finished).with(lot).returns(mock(:deliver => :true))
    AuctionMailer.expects(:win_confirmation_to_renter).never
    lot.send(:run_finish_callbacks)
  end
  
  it "should have active status" do
    lot = Lot.new(@attributes)
    lot.status.should == 'active'
    lot.active?.should be_true
  end
  
  it "should have not active status" do
    lot = Lot.new(@attributes.merge(:start_at => 1.days.from_now))
    lot.status.should == 'not active'
  end
  
  it "should have finished status" do
    lot = Lot.new(@attributes.merge(:start_at => 2.days.ago, :end_at => 1.day.ago))
    lot.status.should == 'finished'
    lot.finished?.should be_true
  end
  
  describe "with bids" do
    before do
      Lot.any_instance.stubs(:run_created_callbacks)
      Bid.any_instance.stubs(:creation_notification)
      @lot = Lot.create!(@attributes)
      @lot.bids.create!(:cents => 4000, :user_id => 1)
    end
    
    it "should send finish notifications to renter" do
      AuctionMailer.stubs(:lot_finished).returns(mock(:deliver => :true))
      AuctionMailer.expects(:win_confirmation_to_renter).with(@lot).returns(mock(:deliver => :true))
      @lot.send(:run_finish_callbacks)
    end
    
    it "should be saveable" do
      @lot.update_attributes(:title => 'Title changes').should be_true
    end
    
    it "should disallow to change cents" do
      @lot.update_attributes(:min_bid_cents => 100).should be_false
    end
    
    it "should return current bid, current bids, next bid cents" do
      @lot.current_bid_cents.should == 4000
      @lot.next_bid_cents.should == 5000
      @lot.current_bids.should have(1).record
      @lot.current_bid.should_not be_nil
    end
  end
end
