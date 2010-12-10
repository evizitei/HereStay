class CanvasController < ApplicationController
  layout 'canvas'
  before_filter :oauth_obj
  
  def index
    search_setup
  end
  
protected
  def search_setup
    @search = params[:search]
    if @search
      #search_obj = RentalUnit.search{ keywords params[:search]; paginate :page =>(params[:page] || 1), :per_page => 5}
      search_obj = RentalUnit.advanced_search(params, current_user)
      p search_obj
      @rental_units = search_obj.results
      @paginate_obj = search_obj.hits
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
      @paginate_obj = @rental_units
    end
  end
end
