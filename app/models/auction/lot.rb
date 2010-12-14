class Lot < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  attr_accessor :creator
  
  belongs_to :property, :class_name => 'RentalUnit', :foreign_key => :property_id
  has_many :bids, :dependent => :destroy
  
  validates :title, :start_at, :end_at, :min_bid_cents, :terms, :property_id, :min_bid_amount, :presence => true
  validates_numericality_of :min_bid_amount, :greater_than_or_equal_to => 0, :allow_blank => :true, :if => Proc.new{|l| l.accept_bids_under_minimum?}
  validates_numericality_of :min_bid_amount, :greater_than => 0, :allow_blank => :true, :unless => Proc.new{|l| l.accept_bids_under_minimum?}
  
  validate :check_dates, :validate_creator
  validate :validate_min_bid_amount, :on => :update
  # validate :check_dates_on_create, :on => :create
  # validate :check_dates_on_update, :on => :update
  
  composed_of :min_bid_amount, :class_name => "Money", :mapping => %w(min_bid_cents cents)
  
  after_create :run_created_callbacks
  
  def initialize(attrs = {})
    super(attrs)
    self.min_bid_cents ||= 0
  end
  
  def belongs_to?(user)
    property.user == user
  end
  
  def current_bids
    self.bids(true).by_cents
  end
  
  def current_bid
    current_bids.first
  end
  
  # latest bid or start bid in cents
  def current_bid_cents
    if self.current_bids.blank?
      min_bid_cents
    else
      self.bids(true).by_cents.first.cents
    end
  end
  memoize :current_bid_cents
  
  # current bid + $10
  def next_bid_cents
    if current_bid.blank?
      accept_bids_under_minimum? ? 0 : min_bid_cents
    else
      current_bid_cents + 1000
    end
  end
  
  def current_bid_amount; Money.new(current_bid_cents); end
  def next_bid_amount; Money.new(next_bid_cents); end
  
  def finish!
    self.end_at = Time.now
    save(:validate => false)
    run_finish_callbacks
  end
  
  def status
    if start_at < Time.zone.now && end_at > Time.zone.now
      'active'
    elsif end_at < Time.zone.now
      'finished'
    else
      'not active'
    end
  end
  
  def active?
    status == 'active'
  end
  
  def finished?
    status == 'finished'
  end
  
  private
  
  def check_dates
    errors.add(:end_at, "should be greater than start date") if start_at && end_at && start_at >= end_at
  end
  
  # Disable validation
  # def check_dates_on_create
  #   errors.add(:start_at, "should be greater than now") if start_at && start_at < Time.zone.now
  # end
  # 
  # def check_dates_on_update
  #   errors.add(:start_at, "should be greater than now") if start_at && start_at_changed? && start_at < start_at_was
  # end
  
  def validate_min_bid_amount
    errors.add(:min_bid_amount, "can't be changed when the auction has bids") if min_bid_cents_changed? && self.bids.present?
  end
  
  def validate_creator
    errors.add(:property_id, "the property belongs to another user") if creator && property && !self.belongs_to?(creator)
  end
  
  def run_finish_callbacks
    AuctionMailer.lot_finished(self).deliver
    AuctionMailer.win_confirmation_to_renter(self).deliver if self.bids.present?
  end
  
  def run_created_callbacks
    # AuctionMailer.lot_created(self).deliver
    post_to_twitter
    post_to_wall
  end
  
  def post_to_twitter
    # TODO
    # post to HereStay's twitter
    # post to Owner's twitter
  end
  
  def post_to_wall
    # TODO
    # post to HereStay's wall
    # post to Owner's wall
  end
end
