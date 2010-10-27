require 'vrbo_proxy'
class VrboListing
  include VrboProxy
  
  # Usage:
  # vl = VrboListing.new(user.vrbo_login, user.vrbo_password)

  # get all active lisitngs:
  # active_vrbo_lising = vl.listings([1,2,3])
  def listings
    listings_for(listing_ids)
  end
  
  # get active listing except listings except exception id list
  # active_vrbo_lising = vl.listings_except([1,2,3])
  def listings_except(except_ids)
    ids = listing_ids - except_ids
    listings_for(ids)
  end
  
  # get listing attributes for vrbo listing with id 123
  # vl.lisitng_attributes(123)
  def lisitng_attributes(listing_id)
    rental_unit = {}
    rental_unit[:vrbo_id] = listing_id
    
    # get general inf
    page = @agent.get("https://admin.vrbo.com/admin/rentalp.aspx?listing=#{listing_id}")
    form = page.form('aspnetForm')

    rental_unit[:name] = form.send('ctl00$Main$tbHeadline')
    # rental_unit[:property_type] = form.send('ctl00$Main$dlPropertyType')
    # rental_unit[:owner_keywords] = form.send('ctl00$Main$tbOwnerKeywords')
    # rental_unit[:bedrooms] = form.send('ctl00$Main$tbBedrooms')
    # rental_unit[:brplus] = form.send('ctl00$Main$lbBRPlus')
    # rental_unit[:bathplus] = form.send('ctl00$Main$lbBathPlus')
    # rental_unit[:sleeps_in_beds] = form.send('ctl00$Main$tbSleepsInBeds')
    # rental_unit[:sleeps] = form.send('ctl00$Main$tbSleeps')
    
    # get  listing's address
    page = @agent.get("https://admin.vrbo.com/admin/rfa/ChangeAddress.aspx?listing=#{listing_id}")
    form = page.form('aspnetForm')
    rental_unit[:address] = form.send('ctl00$Main$address1')
    rental_unit[:address_2] = form.send('ctl00$Main$address2')
    rental_unit[:city] = form.send('ctl00$Main$city')
    rental_unit[:state] = form.send('ctl00$Main$state')
    rental_unit[:zip] = form.send('ctl00$Main$postalCode')
    rental_unit[:country] = form.send('ctl00$Main$geoCountry')
    
    # get lisitng description
    page = @agent.get("https://admin.vrbo.com/admin/rentald.aspx?listing=#{listing_id}")
    form = page.form('aspnetForm')
    rental_unit[:description] = form.send('ctl00$Main$tbLongDesc')
    
    rental_unit
  end
  
  private
  
  # collect listing ids form admin.vrbo.com/admin
  # TODO: should we collect Inactive, Incomplete, Pending Approval?
  # Currently we collect active listings only.
  # Is the pagination used on the admin.vrbo.com/admin ?
  # Curently we does not process pagination
  def listing_ids
    page = @agent.get("https://admin.vrbo.com/admin")
    page.search(".prop-card.active").collect{|e| e[:id]}
  end
  
  def listings_for(ids)
    ids.map{|id| lisitng_attributes(id)}
  end
end