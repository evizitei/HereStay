class AuctionMailer < ActionMailer::Base
  default :from => "donotreply@herestay.com"
  
  def lot_created(lot)
    mail(:to => lot.property.user.email, :subject => "Auction created") do |format|
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
    mail(:to => lot.property.user.email, :subject => "Auction finished")
  end
  
  def win_confirmation_to_renter(bid)
    mail(:to => bid.user.email, :subject => "Win confirmation") do |format|
      format.html { render :text => "<p>You have won the auction.</p> Auction details: #{auction_lot_url(bid.lot)}" }
    end
  end
  
  def booking_error_to_owner(bid, booking)
    @bid = bid
    @booking = booking
    @lot = bid.lot
    
    mail(:to => @lot.property.user.email, :subject => "Booking was not created")
  end
end