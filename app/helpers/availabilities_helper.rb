module AvailabilitiesHelper
  
  def calendar
    options ={}
    today = Date.today
    options[:month] = params[:month].blank? ? today.mon : params[:month].to_i
    options[:year] = params[:year].blank? ? today.year : params[:year].to_i
    if today.mon > options[:month]
      options[:month_state] = 'last'
    elsif today.mon == options[:month]
      options[:month_state] = 'current'
      options[:cur_day] = today.day
    else
      options[:month_state] = 'future'
    end
    options[:days] = month_days(options[:month],options[:year])
    options[:first_day_date] = Time.mktime(options[:year], options[:month], 1)
    options[:first_day] = options[:first_day_date].wday    
    options[:cur_month_name] = options[:first_day_date].strftime("%B")   
    options[:prev_m] = options[:month] == 1 ? 12 : options[:month] - 1
    options[:prev_y] = options[:prev_m] == 12 ? options[:year] - 1 : options[:year]
    options[:prev_days] = month_days(options[:prev_m], options[:prev_y])
    options[:next_m] = options[:month] == 12 ? 1 :options[:month] + 1
    options[:next_y] = options[:next_m] == 1 ? options[:year] + 1 : options[:year]
    options[:first_day] = (options[:first_day] == 0 && options[:first_day_date]) ? 7 : options[:first_day]
    
    booking_ids = @rental_unit.bookings.active.map(&:id)
    month_first_day = Time.mktime(options[:year], options[:month], 1)
    month_last_day = month_first_day + 1.month
    reservations = Reservation.where("booking_id in (?) AND start_at >= ? AND end_at < ?", booking_ids, month_first_day, month_last_day)
    #find event start dates to mark it
    options[:start_days] = reservations.map(&:start_at).flatten.collect{|d| d.day}.uniq
    #find event end dates to mark it
    options[:end_days] = reservations.map(&:end_at).flatten.collect{|d| d.day}.uniq
    #find event days to mark it
    options[:busy_days] = reservations.collect{|r| (r.start_at.to_date..r.end_at.to_date).to_a}.flatten.collect{|d| d.day}.uniq
    
    render :partial => 'shared/mcalendar.html.haml', :locals => {:options => options}
  end
  
  def month_days(month, year = Date.today.year)
    mdays = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    mdays[2] = 29 if Date.leap?(year)
    mdays[month]
  end  
end
