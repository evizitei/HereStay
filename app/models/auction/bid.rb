class Bid < ActiveRecord::Base
  belongs_to :lot
  belongs_to :user
  
  validates :user_id, :lot_id, :presence => true
  validate :validate_cents, :validate_lot
  validates_numericality_of :cents, :greater_than => 0, :allow_blank => :false
  
  before_update :raise_read_only
  before_destroy :raise_read_only
  after_create :creation_notification
  
  composed_of :amount, :class_name => "Money", :mapping => %w(cents cents)
  
  scope :by_cents, order('cents DESC')
  
  def win!
    AuctionMailer.win_confirmation_to_renter(self).deliver
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

end
