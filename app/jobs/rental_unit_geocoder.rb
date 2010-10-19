require 'geokit'

class RentalUnitGeocoder
  def initialize(rental_unit)
    @unit_id = rental_unit.id
  end
  
  def perform
    unit = RentalUnit.find(@unit_id) 
    unit.update_attributes!(:geocoded_at=>DateTime.now)
    result = Geokit::Geocoders::MultiGeocoder.geocode("#{unit.address}, #{unit.city}, #{unit.state}, #{unit.zip}")
    if result.success
      unit.geocoding_success = true
      unit.lat = result.lat
      unit.long = result.lng
      unit.geocoded_address = result.full_address
    else
      unit.geocoding_success = false
      puts "FAILED TO GEOCODE!"
    end
    unit.save!
  end
end