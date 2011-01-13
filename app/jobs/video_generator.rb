class VideoGenerator
  def initialize(rental_unit_id)
    @rental_unit_id = rental_unit_id
  end
  
  def perform
    RentalUnit.find(@rental_unit_id).generate_video_and_upload
  end
end