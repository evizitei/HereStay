require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe RentalUnit do
  disconnect_sunspot
  before do
    TwitterWrapper.stubs(:post_unit_added).returns(true)
    TwitterWrapper.stubs(:post_unit_rented).returns(true)
    GoogleApi.stubs(:geocoder).returns({:lat => 55.1229999, :long => 73.6416001, :geocoded_address => 'Address, City, State, ZIP, Country'})
    @attributes = {
      :name => 'Rental Unit',
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
    unit = RentalUnit.create!(:name => 'Rental Unit', :weekly_low_price => 0.to_f)
    unit.price_from.should be_blank
  end
  
  it 'should not return min price' do
    unit = RentalUnit.create!(:name => 'Rental Unit')
    unit.price_from.should be_blank
  end
  
  it "should return full address" do
    unit = RentalUnit.new(:address => 'Address', :address_2 => 'Address2', :state => 'State', :zip => 'ZIP', :country => 'Country', :city => 'City')
    unit.full_address.should == 'Address, Address2, City, State, ZIP, Country'
    unit = RentalUnit.new(:address => 'Address', :address_2 => '', :state => 'State', :zip => 'ZIP', :country => 'Country', :city => 'City')
    unit.full_address.should == 'Address, City, State, ZIP, Country'
  end
  
  it "should return full address" do
    GoogleApi.stubs(:geocoder).returns(false)
    unit = RentalUnit.new(:name => 'Name', :address => 'Address', :address_2 => 'Address2', :state => 'State', :zip => 'ZIP', :country => 'Country', :city => 'City')
    unit.valid?.should == false
    unit.should have(1).errors_on(:base)
  end
end
