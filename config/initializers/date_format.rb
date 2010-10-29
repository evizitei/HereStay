date_formats = {
  :us_date => '%m/%d/%Y', # MM/DD/YYYY
  :short_date => "%a, %d" # Mar, 10
}

Time::DATE_FORMATS.merge!(date_formats)
Date::DATE_FORMATS.merge!(date_formats)