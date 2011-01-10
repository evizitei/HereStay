require 'spec_helper'

describe Booking do
  it "should post to application twitter when unit rented" do
    user = Factory(:user)
    rental_unit = Factory(:rental_unit, :user => user)
    booking = Factory(:booking, :rental_unit => rental_unit)
    FacebookProxy.expects(:post_unit_rented).with(booking)
    TwitterWrapper.expects(:post_unit_rented).with(booking)
    booking.reserve!
  end
end
