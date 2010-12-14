date_formats = {
  :us_date => '%m/%d/%Y', # MM/DD/YYYY
  :us_short_date => lambda { |date| date.strftime("%m/#{date.day.to_i}/%y") }, # MM/D/YY
  :us_datetime => '%m/%d/%Y %H:%M',
  :us_long_datetime => '%m/%d/%Y %H:%M:%S',
  :short_date => "%a, %d", # Mar, 10,
  :short_date_with_year => "%a %d, %Y" # Mar 10, 2010
}

Time::DATE_FORMATS.merge!(date_formats)
Date::DATE_FORMATS.merge!(date_formats)