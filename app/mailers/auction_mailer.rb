class AuctionMailer < ActionMailer::Base
  default :from => "donotreply@here-stay.com"
  
  def lot_created(lot)
    mail(:to => lot.property.user.email) do |format|
      format.html { render :text => "<p>You have created new autcion lot.</p> Lot details: #{auction_lot_url(lot)}" }
    end
  end
  
  def bid_created_to_owner(bid)
    mail(:to => bid.lot.property.user.email) do |format|
      format.html { render :text => "<p>You have a new bid.</p> Lot details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
  def bid_created_to_renter(bid)
    mail(:to => bid.user.email) do |format|
      format.html { render :text => "<p>You have created a new bid.</p> Lot details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
  def lot_finished(lot)
    if lot.bids.present?
      text = "<p>Your auction lot has finished. The win bid is #{Money.new(lot.bids.last.cents)}.</p>"
    else
      text = "<p>Your auction lot has finished. There are no bids.</p>"
    end
    mail(:to => lot.property.user.email) do |format|
      format.html { render :text => "#{text} Lot details: #{auction_lot_url(lot)}" }
    end
  end
  
  def win_confirmation_to_renter(lot)
    bid = lot.bids.last
    mail(:to => bid.user.email) do |format|
      format.html { render :text => "<p>You have won the auction lot.</p> Lot details: #{auction_lot_url(lot)}" }
    end
  end
  
end