class RentalUnitGeocoder
  def initialize(rental_unit)
    @unit_id = rental_unit.id
  end
  
  def perform
    unit = RentalUnit.find(@unit_id)
    res = GoogleApi.geocoder(unit.full_address)
    if res
      unit.attributes = res
      unit.geocoding_success = true
    else
      unit.geocoding_success = false
    end
    unit.geocoded_at = Time.now
    unit.save(:validation => false)
  end
end