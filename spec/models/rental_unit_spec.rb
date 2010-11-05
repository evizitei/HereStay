require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe RentalUnit do
  disconnect_sunspot
  before do
    RentalUnit.any_instance.stubs(:rented_twitter_post).returns(true)
    RentalUnit.any_instance.stubs(:added_twitter_post).returns(true)
    
    @attributes = {
      :nightly_high_price => 10.to_f,
      :nightly_mid_price => 5.to_f,
      :nightly_high_price => 1.to_f,
      :weekly_high_price => 100.to_f
    }
  end
  
  it 'should return min price' do
    unit = RentalUnit.create!(@attributes)
    unit.price_from.should == 'Price from $1.0'
  end
  
  it 'should not return min price greater 0' do
    unit = RentalUnit.create!(@attributes.merge(:weekly_low_price => 0.to_f))
    unit.price_from.should == 'Price from $1.0'
  end
  
  it 'should not return min price greater 0' do
    unit = RentalUnit.create!(:weekly_low_price => 0.to_f)
    unit.price_from.should be_blank
  end
  
  it 'should not return min price' do
    unit = RentalUnit.create!({})
    unit.price_from.should be_blank
  end
end
