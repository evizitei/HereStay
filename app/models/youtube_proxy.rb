require 'net/http'
require 'net/https'
require 'nokogiri'

class YoutubeProxy
  def get_auth_token(username,password)
    http = Net::HTTP.new("www.google.com", 443)
    http.use_ssl = true
    data = "Email=#{username}&Passwd=#{password}&service=youtube&source=micasasucasafb"
    headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
    resp, data = http.post('/youtube/accounts/ClientLogin', data, headers)
    data.split("\n")[0].split("=")[1]
  end
  
  def get_upload_token(auth_token,title,description)
    data = get_upload_token_response(auth_token,title,description)
    doc = Nokogiri.parse(data)
    {:url=>doc.xpath("//response/url").first.content,:token=>doc.xpath("//response/token").first.content}
  end
  
  def get_upload_token_response(auth_token,title,description)
    http = Net::HTTP.new("gdata.youtube.com")
    headers = {
      'Authorization'=> %Q{GoogleLogin auth=#{auth_token}},
      'GData-Version'=>'2',
      'X-GData-Key'=>%Q{key=#{YOUTUBE_API_KEY}},
      'Content-Type'=>%Q{application/atom+xml; charset=UTF-8}
    }
    xml = %Q{<?xml version="1.0"?>
      <entry xmlns="http://www.w3.org/2005/Atom"
        xmlns:media="http://search.yahoo.com/mrss/"
        xmlns:yt="http://gdata.youtube.com/schemas/2007">
        <media:group>
          <media:title type="plain">#{title}</media:title>
          <media:description type="plain">#{description}</media:description>
          <media:category
            scheme="http://gdata.youtube.com/schemas/2007/categories.cat">Travel
          </media:category>
          <media:keywords>vacation, house, rental</media:keywords>
        </media:group>
      </entry>}
    resp, data = http.post('/action/GetUploadToken', xml, headers)
    return data
  end
end