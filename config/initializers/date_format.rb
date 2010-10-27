date_formats = {
  :us_date => '%m/%d/%Y', # MM/DD/YYYY
}

Time::DATE_FORMATS.merge!(date_formats)
Date::DATE_FORMATS.merge!(date_formats)