class LoadPhoto
  def initialize(rental_unit_id, image_urls)
    @rental_unit_id = rental_unit_id
    @image_urls = image_urls
  end
  
  def perform
    @image_urls.each do |image_url|
      Photo.create({:image_url => image_url, :rental_unit_id => @rental_unit_id})
    end
  end
end