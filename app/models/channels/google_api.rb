require "httparty"
require 'cgi'
class GoogleApi
  def self.geocoder(address)
    begin
      response = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{CGI::escape("#{address}")}&sensor=false")
      response = response.parsed_response
      if response["status"] == "OK"
        result = response["results"].first
        lat_lng = result["geometry"]["location"]
        {:lat => lat_lng["lat"], :long => lat_lng["lng"], :geocoded_address => result["formatted_address"]}
      else
        false
      end
    rescue => err
      Rails.logger.error { "GoogleApi.geocoder error: #{err}. Address is: #{address}" }
      false
    end  
  end
end