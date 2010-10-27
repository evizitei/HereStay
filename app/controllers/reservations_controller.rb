require 'vrbo_proxy'
class ReservationsController < InheritedResources::Base
  rescue_from VrboProxy::Error, :with => :show_errors
  
  belongs_to :my_rental_unit, :class_name => "RentalUnit"
  layout 'canvas'
  helper_method :parent
  
  helper :all
  
  def create
    create!(:location => collection_url, :notice => 'Reservation was created successfully.')
  end
  
  def update
    update!(:location => collection_url, :notice => 'Reservation was updated successfully.')
  end
  
  # import reservation from vrbo.com
  def import
    Reservation.import_for_rental_unit(parent)
    flash[:notice] = 'Reservation were imported successfully.'
    respond_to do |format|
      format.html{redirect_to collection_url}
    end
  end
  
  private
    def collection
      @reservations ||= end_of_association_chain.by_start_time.paginate(:page => params[:page], :per_page => 15)
    end
    
    def show_errors(err)
      flash[:alert] = "Error: #{err.to_s}"
      respond_to do |format|
        format.html{redirect_to collection_url}
      end
    end
end