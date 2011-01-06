class Deal < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessor :creator, :process
  
  belongs_to :user
  belongs_to :rental_unit
  
  composed_of :amount, :class_name => "Money", :mapping => %w(cents cents)
  
  validates :start_on, :end_on, :cents, :amount, :percent, :presence => true, :unless => Proc.new{|d| d.process}
  validates_numericality_of :amount, :greater_than => 0, :allow_blank => :true, :unless => Proc.new{|d| d.process}
  validates_numericality_of :percent, :greater_than => 0, :allow_blank => :true, :unless => Proc.new{|d| d.process}
  validate :check_dates, :validate_creator, :unless => Proc.new{|d| d.process}
  
  validates :user, :presence => true, :on => :update, :if => Proc.new{|d| d.process}
  validate :validate_status, :on => :update, :if => Proc.new{|d| d.process}
  
  after_create :run_created_callbacks
  
  scope :active, where(:status => 'active')
  scope :with_rental_unit_ids, lambda{|rental_unit_ids| where(:rental_unit_id => rental_unit_ids )}
  
  def active?
    status == 'active'
  end
  
  def belongs_to?(u)
    u && self.rental_unit.user == u
  end
  
  def fb_url
    "http://apps.facebook.com/#{Facebook::APP_NAME}" + deal_path(self)
  end
  
  def make_with_user(u)
    self.process = true
    self.user = u
    self.status = 'completed'
    self.save!
    
    booking = self.rental_unit.bookings.build(:start_date => self.start_on, :stop_date => self.end_on,
      :amount => self.amount.to_f, :renter_fb_id => user.fb_user_id
      )
    if booking.save
      booking.reserve!
    else
      UserMailer.deal_booking_error_to_owner(self, booking).deliver
    end
  end
  
  private
  def check_dates
    errors.add(:end_on, "should be greater than start date") if start_on && end_on && start_on >= end_on
  end
  
  def validate_status
    errors.add(:status, "not active") unless status_was == 'active'
  end
  
  def validate_creator
    errors.add(:rental_unit_id, "the property belongs to another user") if creator && rental_unit && !self.belongs_to?(creator)
  end
  
  def run_created_callbacks
    # TwitterWrapper.post_deal_added(self)
    options = {
      :message => "Deal #{self.rental_unit.name} has been added.",
      :link => self.fb_url,
      :name => 'view deal details',
      :picture=> self.rental_unit.picture(:medium) || ''
    }
    FacebookProxy.new(:here_stay).put_object(:here_stay, "feed", options)
    if self.rental_unit.user.subscribed? && self.rental_unit.user.subscription_plan == 'advanced'
      FacebookProxy.new(self.rental_unit.user.access_token).put_object('me', "feed", options)
    end
  end
end
