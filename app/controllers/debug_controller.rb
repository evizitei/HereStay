require 'geokit'

class DebugController < ApplicationController
  def geocode
    if params[:address]
      @coordinates = Geokit::Geocoders::MultiGeocoder.geocode(params[:address])
    end
  end
end
