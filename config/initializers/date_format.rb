date_formats = {
  :us_date => '%m/%d/%Y', # MM/DD/YYYY
  :us_short_date => lambda { |date| date.strftime("%m/#{date.day.to_i}/%y") }, # MM/D/YY
  :short_date => "%a, %d" # Mar, 10
}

Time::DATE_FORMATS.merge!(date_formats)
Date::DATE_FORMATS.merge!(date_formats)