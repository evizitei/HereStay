class Admin::BaseController < ApplicationController
  before_filter :require_admin
  
  def require_admin
    true
  end
end