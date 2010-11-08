class CanvasController < ApplicationController
  before_filter :oauth_obj
  
  def index
    search_setup
  end
  
protected
  def search_setup
    @search = params[:search]
    if @search
      search_obj = RentalUnit.search{ keywords params[:search]; paginate :page =>(params[:page] || 1), :per_page => 5}
      @rental_units = search_obj.results
      @paginate_obj = search_obj.hits
    else
      @rental_units = RentalUnit.paginate(:page=>params[:page] || 1,:order=>"created_at DESC")
      @paginate_obj = @rental_units
    end
  end
end
