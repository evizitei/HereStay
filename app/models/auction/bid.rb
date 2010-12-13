class Bid < ActiveRecord::Base
  belongs_to :lot
  belongs_to :user
  
  validates :cents, :user_id, :lot_id, :presence => true
  validates :cents, :numericality => true, :allow_blank => true
  validate :validate_cents, :validate_lot
  before_update :raise_read_only
  before_destroy :raise_read_only
  after_create :creation_notification
  
  composed_of :amount, :class_name => "Money", :mapping => %w(cents cents)
  
  private
  def validate_cents
    errors.add(:cents, "should be greater or equal #{lot.current_bid.format}") if self.cents && self.cents < lot.current_bid_cents
  end
  
  def validate_lot
    errors.add(:base, "Auction lot should be active") unless self.lot.active?
  end
  
  def creation_notification
    AuctionMailer.bid_created_to_owner(self).deliver
    AuctionMailer.bid_created_to_renter(self).deliver
  end

end
