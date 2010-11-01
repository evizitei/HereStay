class Reservation < ActiveRecord::Base
  attr_accessor :save_on_remote_server
  
  STATUSES = %w(RESERVE HOLD UNAVAILABLE CANCEL)
  BUSY_STATUSES = %w(RESERVE UNAVAILABLE)
  VRBO_SEARCH_STATUSES = {'RESERVE' => 'Booked', 'HOLD' => 'Tentative', 'UNAVAILABLE' => 'Unavailable', 'CANCEL' => 'Cancelled'}
  belongs_to :rental_unit
  
  validates_inclusion_of  :status, :in => STATUSES
  validates_presence_of   :start_at, :end_at, :rental_unit_id
  validates_uniqueness_of :remote_id, :scope => :rental_unit_id, :unless => Proc.new{|a| a.remote_id.blank?}
  
  validates_length_of :zip, :country, :maximum=>20
  validates_length_of :state, :maximum=>20
  validates_length_of :first_name, :last_name, :phone, :fax, :mobile, :city, :address1, :address2, :email, :maximum=>70
  validates_length_of :notes, :maximum=>3000
  validates_length_of :inquiry_source, :maximum=>50
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i , :allow_blank => true

  validates_numericality_of :number_of_adults, :number_of_children, :only_integer => true, :less_than_or_equal_to => 1000
  validates_numericality_of :number_of_adults, :number_of_children, :greater_than_or_equal_to => 0

  validate :validate_dates, :validate_for_another_reservation

  validates_presence_of :remote_login, :remote_password, :remote_listing_id, :if => :save_on_remote_server?
  
  before_create :set_recently_created
  before_save :sync_with_remote_server, :if => :save_on_remote_server?
  after_destroy :destroy_on_remote_server, :if => Proc.new{|a| a.remote_id.present?}
  
  scope :by_start_time, order('start_at ASC')
  scope :busy, lambda{ where(:status => BUSY_STATUSES) }
  scope :except, lambda{|r| where("id != ?", r.id) }
  
  def remote_listing_id; rental_unit.vrbo_id ; end
  def remote_login ; rental_unit.user.vrbo_login; end
  def remote_password; rental_unit.user.vrbo_password; end
  
  def start_date
    start_at.to_date
  end
  
  def start_hour
    start_at.hour
  end
  
  def end_date
    end_at.to_date
  end
  
  def end_hour
    end_at.hour
  end
  
  def full_name
    [first_name, last_name].compact.join(' ')
  end
  
  def recently_created?
    @recently_created == true
  end
  
  def save_on_remote_server?
    @save_on_remote_server.present? and (@save_on_remote_server === true || @save_on_remote_server.to_s == '1')
  end
  
  def save_on_remote_server
    @save_on_remote_server.present? ? save_on_remote_server? : remote_listing_id.present?
  end
  
  def self.import_for_rental_unit(rental_unit, year = nil)
    vrbo_login = rental_unit.user.vrbo_login
    vrbo_password = rental_unit.user.vrbo_password
    vrbo_id = rental_unit.vrbo_id
    self.import_from_vrbo(vrbo_login, vrbo_password, vrbo_id, rental_unit, year || Time.now.year)
  end
  
  # Import reservations from remote server
  def self.import_from_vrbo(vrbo_login, vrbo_password, vrbo_listing_id, rental_unit, year)
    vr = VrboReservation.new(vrbo_login, vrbo_password, vrbo_listing_id)
    vr.all_reservations.each do |reservation_attrs|
      unless rental_unit.reservations.exists?(:remote_id => reservation_attrs[:remote_id])
        a = rental_unit.reservations.build(reservation_attrs)
        a.save_on_remote_server = false
        a.save!
      end
    end
  end
  
  def vrbo_search_status
    Reservation::VRBO_SEARCH_STATUSES[self.status]
  end

private
  # sync reservation with remote server if it's required
  def sync_with_remote_server
    begin
      if recently_created? || remote_id.blank?
        # TODO: retrive remote_id from exported reservation
          create_on_remote_server
      else
        update_on_remote_server
      end
    rescue VrboProxy::Error => e
      errors.add(:save_on_remote_server, e.to_s)
      false
    end
  end
  
  def update_on_remote_server
    VrboReservation.update_reservation(self)
  end
  
  def create_on_remote_server
    new_remote_id = VrboReservation.create_reservation(self)
    if new_remote_id.present? && !rental_unit.reservations.exists?(:remote_id => new_remote_id)
      self.remote_id = new_remote_id
    end
  end
  
  def destroy_on_remote_server
    VrboReservation.destroy_reservation(self)
  end
  
  def set_recently_created
    @recently_created = true
  end
  
  # don't allow to start_at be greater than end_at
  def validate_dates
    if start_at && end_at
      errors.add(:end_at, 'should be greater than start date') if end_at <= start_at
    end
  end
  
  # don't allow create more than one reservation with status UNAVAILABLE or RESERVE in same period
  def validate_for_another_reservation
    if start_at && end_at && BUSY_STATUSES.include?(self.status)
      errors.add(:start_at, 'Another reservation already exists for these dates.') if exists_other_reservations_in_same_period?
    end
  end
  
  def exists_other_reservations_in_same_period?
     rental_unit.reservations.except(self).busy.exists?([" ? < end_at AND ? > start_at", self.start_at, self.end_at])
  end
end