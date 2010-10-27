require 'vrbo_proxy'
class VrboReservation
  include VrboProxy
  
  attr_accessor :listing_id
  
  # create new reservation
  def self.create_reservation(assignment)
    VrboReservation.save_reservation(assignment, true)
  end
  
  # update exisiting reservation
  def self.update_reservation(assignment)
    VrboReservation.save_reservation(assignment, false)
  end
  
  def self.save_reservation(assignment, new_record = false)
    r = VrboReservation.new(assignment.remote_login, assignment.remote_password, assignment.remote_listing_id)

    url = new_record ? "https://connect.homeaway.com/reservations/create.htm?sessionId=#{r.homeaway_session_id}" : "https://connect.homeaway.com/reservations/edit.htm?sessionId=#{r.homeaway_session_id}&id=#{assignment.remote_id}"
    page = r.agent.get(url)
    form = page.form('reservationForm')
    
    form.arrivalDateString = assignment.start_date.to_s(:us_date)
    form.checkinTime       = assignment.start_hour
    form.departureDateString = assignment.end_date.to_s(:us_date)
    form.checkoutTime = assignment.end_hour
    form.status = assignment.status
    form.inquirySource = assignment.inquiry_source
    form.notes = assignment.notes
    form.firstName = assignment.first_name
    form.lastName = assignment.last_name
    form.email = assignment.email
    form.numAdults = assignment.number_of_adults
    form.numChildren = assignment.number_of_children
    form.phone = assignment.phone
    form.mobile = assignment.mobile
    form.fax = assignment.fax
    form.addr1 = assignment.address1
    form.addr2 = assignment.address2
    form.city = assignment.city
    form.stateProvince = assignment.state
    form.zip = assignment.zip
    form.country = assignment.country
    
    page = r.agent.submit(form)
    raise Error, 'Impossible to save assignment on the remote server' if page.form('reservationForm').present?
    # return true if reservationForm not present after submit
    true
  end

  # destroy exisiting reservation
  def self.destroy_reservation(assignment)
    r = VrboReservation.new(assignment.remote_login, assignment.remote_password, assignment.remote_listing_id)
    page = r.agent.get("https://connect.homeaway.com/reservations/delete.htm?sessionId=#{r.homeaway_session_id}&id=#{assignment.remote_id}")
  end
  
  # collect links to edit reservation forms, parse them and return reservations
  def reservations(year = nil)
    page = search_reservations(year)
    links = page.links.find_all{|l| l.text =~ /Edit\sDetails/}
    links.map{|l| reservation_attributes(l.href)}
  end
  
private
  # parse a reservation edit form and build reservation attributes
  def reservation_attributes(link)
    page = @agent.get("https://connect.homeaway.com#{link}")
    form = page.form('reservationForm')
    {
      :remote_id      => get_reservation_id(link),
      :start_at       => DateTime.parse(form.arrivalDateString + " " + form.checkinTime),
      :end_at         => DateTime.parse(form.departureDateString + " " + form.checkoutTime),
      :notes          => form.notes,
      :status         =>  form.status,
      :first_name     => form.firstName,
      :last_name      => form.lastName,
      :email          => form.email,
      :number_of_adults   => form.numAdults.to_i,
      :number_of_children => form.numChildren.to_i,
      :phone          => form.phone,
      :mobile         => form.mobile,
      :fax            => form.fax,
      :address1       => form.addr1,
      :address2       => form.addr2,
      :city           => form.city,
      :state          => form.stateProvince,
      :zip            => form.zip,
      :country        => form.country,
      :inquiry_source => form.inquirySource
    }
  end
  
  # Post a reservation search form
  def search_reservations(year = nil)
    params = { 'periodType' => 'periodTypeYear', 'searchMode' => 0, 'sortBy' => 'ARRIVAL_DATE',
      'sortByAscending' => 'true', 'status' => 'All', 'submit' => 'Find', 'year' => year || Date.today.year
    }
    agent.get("https://connect.homeaway.com/reservations/list.htm?sessionId=#{homeaway_session_id}", params)
  end
  
  
  # extract reservation id from url
  def get_reservation_id(link)
    uri = Addressable::URI.parse(link)
    uri.query_values['id']
  end
  
  # get calendar for listing
  # 'https://admin.vrbo.com/admin/calendar.aspx?listing=305472'
  def get_vrbo_calendar_page
    check_lisitng_id
    
    url = "https://admin.vrbo.com/admin/calendar.aspx?listing=#{@listing_id}"
    @agent.get(url)
  end
end