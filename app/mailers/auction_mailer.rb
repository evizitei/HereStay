class AuctionMailer < ActionMailer::Base
  default :from => "donotreply@here-stay.com"
  
  def lot_created(lot)
    mail(:to => lot.property.user.email) do |format|
      format.html { render :text => "<p>You have created new auction.</p> Auction details: #{auction_lot_url(lot)}" }
    end
  end
  
  def bid_created_to_owner(bid)
    mail(:to => bid.lot.property.user.email, :subject => "New bid") do |format|
      format.html { render :text => "<p>You have a new bid.</p> Auction details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
  def bid_created_to_renter(bid)
    mail(:to => bid.user.email, :subject => "New bid") do |format|
      format.html { render :text => "<p>You have created a new bid.</p> Auction details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
  def lot_finished(lot)
    @lot = lot
    mail(:to => lot.property.user.email)
  end
  
  def win_confirmation_to_renter(bid)
    mail(:to => bid.user.email, :subject => "Win confirmation") do |format|
      format.html { render :text => "<p>You have won the auction.</p> Auction details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
end