class Auction::BaseController < ApplicationController
  layout 'application'
  private
  def format_money_params
    if params[:bid] && params[:bid][:amount]
      params[:bid][:amount] = params[:bid][:amount].to_money
    end
    
    if params[:lot] && params[:lot][:min_bid_amount]
      params[:lot][:min_bid_amount] = params[:lot][:min_bid_amount].to_money
    end
  end
end