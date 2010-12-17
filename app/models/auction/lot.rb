class Lot < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessor :creator
  
  belongs_to :property, :class_name => 'RentalUnit', :foreign_key => :property_id
  has_many :bids, :dependent => :destroy, :order => 'cents DESC'
  
  validates :title, :start_at, :end_at, :min_bid_cents, :terms, :property_id, :min_bid_amount, :presence => true
  validates_numericality_of :min_bid_amount, :greater_than_or_equal_to => 0, :allow_blank => :true, :if => Proc.new{|l| l.accept_bids_under_minimum?}
  validates_numericality_of :min_bid_amount, :greater_than => 0, :allow_blank => :true, :unless => Proc.new{|l| l.accept_bids_under_minimum?}
  
  validate :check_dates, :validate_creator
  validate :validate_min_bid_amount, :on => :update
  validate :validate_expiration, :on => :update
  # validate :check_dates_on_create, :on => :create
  # validate :check_dates_on_update, :on => :update
  
  composed_of :min_bid_amount, :class_name => "Money", :mapping => %w(min_bid_cents cents)
  
  after_create :run_created_callbacks
  
  scope :not_completed, where(:completed => false)
  scope :expired, where(["end_at < ?", Time.zone.now])
  
  def initialize(attrs = {})
    super(attrs)
    self.min_bid_cents ||= 0
  end
  
  def belongs_to?(user)
    property.user == user
  end
  
  def current_bids
    self.bids(true)
  end
  
  # latest bid
  def current_bid
    current_bids.first
  end
  
  # current bid + $10
  def next_bid_cents
    if current_bid.blank?
      accept_bids_under_minimum? ? 0 : min_bid_cents
    else
      current_bid.cents + 1000
    end
  end
  
  def next_bid_amount; Money.new(next_bid_cents); end
  
  def finish!
    self.end_at = Time.now # TODO: remove Finish button and this line before release.
    self.completed = true
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
  
  def winning_bid
    if self.finished?
      bids.winning.first || not_confirmed_winning_bid
    end
  end
  
  # current bid which is greater than min_bid_cents not marked as winning
  def not_confirmed_winning_bid
    current_bid if current_bid && current_bid.cents >= min_bid_cents
  end
  
  def supposed_winning_bid
    current_bid if self.finished? && accept_bids_under_minimum? && current_bid && current_bid.cents < min_bid_cents
  end
  
  def fb_url
    "http://apps.facebook.com/#{Facebook::APP_NAME}" + auction_lot_path(self)
  end
  
  def user
    self.property.user
  end
  
  def editable?
    end_date = end_at_changed? ? end_at_was : end_at
    !completed? and end_date > Time.now
  end
  
  def self.finish!
    Lot.expired.not_completed.all.each do |lot|
      lot.finish!
    end
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
  
  def validate_expiration
    errors.add(:base, 'Auction is finished and is not editable') unless editable?
  end
  
  def run_finish_callbacks
    AuctionMailer.lot_finished(self).deliver
    
    if current_bid && current_bid.cents >= min_bid_cents
      current_bid.win!
    end
  end
  
  def run_created_callbacks
    # AuctionMailer.lot_created(self).deliver
    TwitterWrapper.post_auction_added(self)
    FacebookProxy.new(:here_stay).put_object(:here_stay, "feed",
      :message => "Auction #{self.title} has been added.",
      :link => self.fb_url,
      :name => 'view auction details',
      :picture=> self.property.picture(:medium) || ''
    )
    
    if user.subscribed? && user.subscription_plan == 'advanced'
      FacebookProxy.new(self.property.user.access_token).put_object('me', "feed",
        :message => "Auction #{self.title} has been added.",
        :link => self.fb_url,
        :name => 'view auction details',
        :picture=> self.property.picture(:medium) || ''
      )
    end
  end
end
