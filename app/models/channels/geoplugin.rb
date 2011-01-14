require "httparty"
require 'cgi'
class Geoplugin
  def self.query(address)
    begin
      response = HTTParty.get("http://www.geoplugin.net/xml.gp?ip=#{CGI::escape("#{address}")}")
      if response["geoPlugin"]
        {:lat => response["geoPlugin"]["geoplugin_latitude"], :lng => response["geoPlugin"]["geoplugin_longitude"], :country => response["geoPlugin"]["geoplugin_countryCode"]}
      else
        false
      end
    rescue => err
      Rails.logger.error { "Geoplugin error: #{err}. IP address is: #{address}" }
      false
    end  
  end
  
  def self.query_latlng(address, true_country_codes = ['US'])
    if (coords = Geoplugin.query(address)) && true_country_codes.include?(coords[:country])
      {:lat => coords[:lat], :lng => coords[:lng]}
    else
      nil
    end
  end	
end