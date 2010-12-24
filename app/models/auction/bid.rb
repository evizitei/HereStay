class Bid < ActiveRecord::Base
  belongs_to :lot
  belongs_to :user
  
  validates :user_id, :lot_id, :presence => true
  validate :validate_cents, :validate_lot
  validates_numericality_of :cents, :greater_than => 0, :allow_blank => :false
  
  after_create :creation_notification
  
  composed_of :amount, :class_name => "Money", :mapping => %w(cents cents)
  
  scope :by_cents, order('cents DESC')
  scope :winning, where(:winning => true)
  
  def win!
    unless self.lot.bids.winning.exists?
      self.winning = true
      self.save(:validate => false)
      AuctionMailer.win_confirmation_to_renter(self).deliver
      # booking = lot.property.bookings.build(:start_date => lot.arrive_on, :stop_date => lot.depart_on,
      #   :amount => self.amount.to_f, :renter_fb_id => user.fb_user_id
      # )
      if booking.save
        booking.reserve!
      else
        AuctionMailer.booking_error_to_owner(self, booking).deliver
      end
    end
  end
  
  private
  def validate_cents
    errors.add(:cents, "should be greater or equal #{lot.next_bid_amount.format}") if self.cents && self.cents < lot.next_bid_cents
  end
  
  def validate_lot
    errors.add(:base, "Auction should be active") unless self.lot.active?
  end
  
  def creation_notification
    AuctionMailer.bid_created_to_owner(self).deliver
    AuctionMailer.bid_created_to_renter(self).deliver
  end
  
  def booking
    @booking ||= build_booking
  end
  
  def build_booking
    lot.property.bookings.build(:start_date => lot.arrive_on, :stop_date => lot.depart_on,
      :amount => self.amount.to_f, :renter_fb_id => user.fb_user_id
    )
  end
  
end
