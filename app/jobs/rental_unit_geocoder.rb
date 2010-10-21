require "httparty"
require 'cgi'

class RentalUnitGeocoder
  def initialize(rental_unit)
    @unit_id = rental_unit.id
  end
  
  def perform
    unit = RentalUnit.find(@unit_id) 
    unit.update_attributes!(:geocoded_at=>DateTime.now)
    response = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{CGI::escape("#{unit.address}, #{unit.city}, #{unit.state}, #{unit.zip}")}&sensor=false"
    response = response.parsed_response
    if response["status"] == "OK"
      result = response["results"].first
      lat_lng = result["geometry"]["location"]
      unit.geocoding_success = true
      unit.lat = lat_lng["lat"]
      unit.long = lat_lng["lng"]
      unit.geocoded_address = result["formatted_address"]
    else
      unit.geocoding_success = false
      puts "FAILED TO GEOCODE!"
    end
    unit.save!
  end
end