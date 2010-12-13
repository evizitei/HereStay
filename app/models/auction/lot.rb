class Lot < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  attr_accessor :creator
  
  belongs_to :property, :class_name => 'RentalUnit', :foreign_key => :property_id
  has_many :bids, :dependent => :destroy
  
  validates :title, :start_at, :end_at, :min_bid_cents, :terms, :property_id, :presence => true
  validate :check_dates, :validate_creator
  validate :check_dates_on_create, :on => :create
  validate :check_dates_on_update, :on => :update
  
  composed_of :amount, :class_name => "Money", :mapping => %w(min_bid_cents cents)
  
  after_create :run_created_callbacks
  
  def belongs_to?(user)
    property.user == user
  end
  
  def current_bid_cents
    if current_bids.blank?
      min_bid_cents
    else
      self.bids(true).last.cents + 1000
    end
  end
  memoize :current_bid_cents
  
  def current_bids
    self.bids(true)
  end
  
  
  def current_bid
    Money.new(current_bid_cents)
  end
  
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
  
  def check_dates_on_create
    errors.add(:start_at, "should be greater than now") if start_at && start_at < Time.zone.now
  end
  
  def check_dates_on_update
    errors.add(:start_at, "should be greater than now") if start_at && start_at_changed? && start_at < start_at_was
  end
  
  def validate_creator
    errors.add(:property_id, "the property belongs to another user") if creator && !self.belongs_to?(creator)
  end
  
  def run_finish_callbacks
    AuctionMailer.lot_finished(self).deliver
    AuctionMailer.win_confirmation_to_renter(self).deliver if self.bids.present?
  end
  
  def run_created_callbacks
    AuctionMailer.lot_created(self).deliver
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
