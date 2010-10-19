class RentalUnitsController < ApplicationController
  # GET /rental_units
  # GET /rental_units.xml
  def index
    @rental_units = RentalUnit.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rental_units }
    end
  end

  # GET /rental_units/1
  # GET /rental_units/1.xml
  def show
    @rental_unit = RentalUnit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rental_unit }
    end
  end

  # GET /rental_units/new
  # GET /rental_units/new.xml
  def new
    @rental_unit = RentalUnit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rental_unit }
    end
  end

  # GET /rental_units/1/edit
  def edit
    @rental_unit = RentalUnit.find(params[:id])
  end

  # POST /rental_units
  # POST /rental_units.xml
  def create
    @rental_unit = RentalUnit.new(params[:rental_unit])

    respond_to do |format|
      if @rental_unit.save
        format.html { redirect_to(@rental_unit, :notice => 'Rental unit was successfully created.') }
        format.xml  { render :xml => @rental_unit, :status => :created, :location => @rental_unit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rental_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rental_units/1
  # PUT /rental_units/1.xml
  def update
    @rental_unit = RentalUnit.find(params[:id])

    respond_to do |format|
      if @rental_unit.update_attributes(params[:rental_unit])
        format.html { redirect_to(@rental_unit, :notice => 'Rental unit was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rental_unit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rental_units/1
  # DELETE /rental_units/1.xml
  def destroy
    @rental_unit = RentalUnit.find(params[:id])
    @rental_unit.destroy

    respond_to do |format|
      format.html { redirect_to(rental_units_url) }
      format.xml  { head :ok }
    end
  end
  
  def gallery
    @rental_unit = RentalUnit.find(params[:id])
    render :layout=>false
  end
  
  def map
    @rental_unit = RentalUnit.find(params[:id])
    render :layout=>'application'
  end
  
  def watch_video
    @rental_unit = RentalUnit.find(params[:id])
    render :layout=>false
  end
end
