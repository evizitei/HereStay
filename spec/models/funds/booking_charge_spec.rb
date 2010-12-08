require 'spec_helper'
require 'ostruct'

# allow call object.id
OpenStruct.__send__(:define_method, :id) { @table[:id] }

describe BookingCharge do
  let(:booking){ Factory(:booking, :rental_unit => Factory(:rental_unit, :user => Factory(:user))) }
  
  it "should not charge the booking fee when booking is created" do
    booking.stubs(:do_reserve!).returns(true)
    booking.update_attributes_and_reserve(:amount => 300).should be_true
    booking.booking_charges.should have(0).records
  end
  
  it "should be charge the booking fee" do
    Recurly::Charge.stubs(:create).returns(OpenStruct.new(:id => 12345))
    booking.stubs(:do_reserve!).returns(true)
    booking.update_attributes_and_reserve(:amount => 300).should be_true
    Booking.charge_booking_fee
    booking.booking_charges.last.cents.should == 300*0.05*100
    booking.booking_charges.last.state.should == 'charged'
  end
  
  it "should not be charged when booking is confirmed" do
    Recurly::Charge.stubs(:create).raises(ActiveRecord::RecordNotFound)
    booking.stubs(:do_reserve!).returns(true)
    booking.update_attributes_and_reserve(:amount => 300).should be_true
    Booking.charge_booking_fee
    booking.booking_charges.last.cents.should == 300*0.05*100
    booking.booking_charges.last.state.should == 'error'
  end
end