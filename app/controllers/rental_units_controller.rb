class RentalUnitsController < ApplicationController
  inherit_resources
  layout 'application'
  before_filter :login_required, :except => %w(index show owned_by availabilities)
  before_filter :subscription_required, :only => %w(manage new create edit update destroy load_from_vrbo import)
  respond_to :html

  def create
    create!(:notice => 'Rental unit was created successfully', :location => manage_rental_units_url)
  end

  def update
    update!(:notice => 'Rental unit was updated successfully', :location => manage_rental_units_url)
  end

  def destroy
    destroy!(:notice => 'Rental unit was destroyed successfully', :location => manage_rental_units_url)
  end
  
  def owned_by
    @rental_units = collection
  end
  
  def manage
    @rental_units = collection
  end
  
  def load_data_from_vrbo
    @rental_unit = current_user.load_property_from_vrbo(params)
    render (@rental_unit.new_record? ? 'new' : 'edit')
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

  def availabilities
    @rental_unit = RentalUnit.find(params[:id])
    respond_to do |format|
      format.html
      format.js{render :partial => 'calendar.html.haml', :object => @rental_unit}
    end
  end
  
  def preview
    @rental_unit = RentalUnit.new(params[:rental_unit])
    #@rental_unit.set_primary_photo(params)
    respond_to do |format|
      if params[:edit_rental_unit].blank? && @rental_unit.valid?
        format.html
      else
        format.html{ render :action => :new}
      end
    end
  end
  
  def preview_update
    @rental_unit = current_user.rental_units.find(params[:id])
    @rental_unit.attributes = params[:rental_unit]
    #@rental_unit.set_primary_photo(params)
    respond_to do |format|
      if params[:edit_rental_unit].blank? && @rental_unit.valid?
        format.html
      else
        format.html{ render :action => :edit}
      end
    end
  end
  
  def search
    search_setup
    render 'index'
  end
  
  def store_last_comment
    @rental_unit = RentalUnit.find(params[:id])
    current_user.store_last_comment_for(@rental_unit)
    render :text => 'ok'
  end
  
  protected
    # Disable not-owner to manage reservations
    def begin_of_association_chain
      # raise self.action_name.inspect
      case self.action_name
        when 'index', 'show' : super
        when 'owned_by' :
          @user=User.find(params[:user_id])
        else
          current_user
      end
    end
    
    def collection
      @rental_units ||= end_of_association_chain.paginate(:page => params[:page], :per_page => 5)
    end
    
    def create_resource(object)
      object.save_photos(params)
      object.save
    end
    
    def update_resource(object, attributes)
      object.attributes = attributes
      object.save_photos(params)
      object.save
    end
    
    def search_setup
      @search = params[:search]
      if @search
        #search_obj = RentalUnit.search{ keywords params[:search]; paginate :page =>(params[:page] || 1), :per_page => 5}
        search_obj = RentalUnit.advanced_search(params, current_user)
        @rental_units = search_obj.results
      else
        # Lsit friends' listings first if user logged-in and has FB friends
        # if current_user && !current_user.fb_friend_ids.blank?
        #   search_obj = RentalUnit.friends_first(current_user.fb_user_id, current_user.fb_friend_ids, params[:page] || 1)
        #   @rental_units = search_obj.results
        #   @paginate_obj = search_obj.hits
        # else
        #   @rental_units = RentalUnit.paginate(:page=>params[:page] || 1,:order=>"created_at DESC")
        #   @paginate_obj = @rental_units
        # end
        @rental_units = RentalUnit.paginate(:page=>params[:page] || 1,:order=>"created_at DESC")
      end
    end
end