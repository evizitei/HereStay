require 'rubygems'
require 'mechanize'
require "addressable/uri"
require 'ostruct'

module VrboProxy
  class Error < Exception; end
  
  def initialize(login, password, listing_id = nil)
    @agent = Mechanize.new
    @login = login
    @password = password
    @listing_id = listing_id
    
    login!
  end
  
  def agent
    @agent
  end
  
  
  def homeaway_session_id
    @session_id ||= get_session_id
  end
  
  private
  # login into VRBO.com
  def login!
    page = @agent.get('https://admin.vrbo.com/admin/Logon.aspx')
    form = page.form('Form1')
    # use send method because input name contains '$'.
    form.send('logonControl$UserId=', @login)
    form.send('logonControl$Pass=', @password)
    page = @agent.submit(form)
    raise Error, 'Invalid login or password for Virbo account'  if page.form('Form1').present?
    true
  end
  
  # get sessionId for connect.homeaway.com
  def get_session_id
    check_lisitng_id
    
    calendar_frame = get_vrbo_calendar_page.iframes.first.src
    page = @agent.get calendar_frame
    link = page.links[3].href
    uri = Addressable::URI.parse(link)
    uri.query_values['sessionId']
  end
  
  def check_lisitng_id
    raise Error, 'Missing listing id' if @listing_id.nil?
  end
end