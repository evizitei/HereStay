class RentalUnitsController < ApplicationController
  before_filter :oauth_obj,  :except => %w(index owned_by)
  before_filter :login_required, :except => %w(index show owned_by)
  before_filter :subscription_required, :only => %w(manage new create edit update destroy load_from_vrbo import)

  respond_to :html

  def index
    @app_page = (params[:profile_id].to_s == "123982284313527")
    if @app_page
      offset = rand(RentalUnit.order("id DESC").limit(1).select("id").first.id - 5) rescue 0
      @rental_units = RentalUnit.order("id ASC").limit(5).where("id >= #{offset}")
    else
      @rental_units = RentalUnit.find_all_by_fb_user_id(params[:profile_id])
      if @rental_units.size == 0
        @app_page = true
        offset = rand(RentalUnit.order("id DESC").limit(1).select("id").first.id - 5) rescue 0
        @rental_units = RentalUnit.order("id ASC").limit(5).where("id >= #{offset}")
      end
    end
  end

  def manage
    @rental_units = current_user.rental_units
  end

  def new
    @rental_unit = RentalUnit.new()
  end

  def edit
    @rental_unit = current_user.rental_units.find(params[:id])
  end

  def create
    @rental_unit = current_user.rental_units.build(params[:rental_unit])
    if @rental_unit.save
      flash[:notice] = 'Rental unit was created successfully'
    end
    respond_with(@rental_unit, :location => manage_rental_units_url)
  end

  def update
    @rental_unit = current_user.rental_units.find(params[:id])
    if @rental_unit.update_attributes(params[:rental_unit])
      flash[:notice] = 'Rental unit was updated successfully'
    end
    respond_with(@rental_unit, :location => manage_rental_units_url)
  end

  def show
    @rental_unit = RentalUnit.find(params[:id])
  end

  def destroy
    @rental_unit = current_user.rental_units.find(params[:id])
    @rental_unit.destroy
    redirect_to manage_rental_units_url
  end

  def load_from_vrbo
    rental_unit = current_user.rental_units.find(params[:id])
    rental_unit.load_from_vrbo!
    flash[:notice] = "Full listing loaded from Vrbo successfully. Photos will be imported in some minutes."
    redirect_to edit_rental_unit_url(rental_unit)
  end

  def import
    rental_units = RentalUnit.import_from_vrbo!(current_user)

    flash[:notice] = t(:'flash.import.completed')
    flash[:notice] << t(:'flash.import.success', :count => rental_units[:success].size)
    flash[:notice] << t(:'flash.import.fail', :count => rental_units[:fail].size) unless rental_units[:fail].blank?
    flash[:notice] << "."
    redirect_to manage_rental_units_url
  end

  def share
    @rental_unit = RentalUnit.find(params[:id])
    render :json => @rental_unit.share_json_for(current_user)
  end
  
  def store_last_post
    fb_stream = current_user.fb_streams.find_or_initialize_by_rental_unit_id(params[:id])
    fb_stream.message = current_user.get_stream_publishing(params[:post_id])
    fb_stream.save
    render :text => 'ok'
  end

  def owned_by
    current_user = User.find params[:user_id]
    @rental_units = current_user.rental_units.paginate(:page => params[:page], :per_page => 1)
  end
end