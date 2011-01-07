module PhotosHelper
  def primary_class(photo)
    params[:preview_image_id] == photo.id.to_s || (params[:preview_image_id].blank? && photo.primary? && photo.rental_unit_id) ? ' primary' : ''
  end
end
