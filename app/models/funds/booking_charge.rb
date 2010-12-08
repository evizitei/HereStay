class BookingCharge < Fund
  
  MIN_CHARGE_CENTS = 10*100
  CHARGE_PERCENT = 5
  
  before_create :set_initial_state
  before_validation :calc_cents, :on => :create
  before_validation :uniq_booking_charge, :on => :create
  after_create :charge_with_recurly, :if => :pending?
  
  # States
  # pending - new record, not processed
  # processed
  # refunded
  # canceled

  def pending?
    self.state == 'pending'
  end
  
  private
  def set_initial_state
    self.state = 'pending'
  end
  
  # calculate booking fee
  def booking_fee
    @booking_fee ||= (self.document.cents * CHARGE_PERCENT/100.0).round
  end
  
  def calc_cents
    self.cents = booking_fee > MIN_CHARGE_CENTS ? booking_fee : MIN_CHARGE_CENTS
  end
  
  # don't allow aplly charge more than 1 time
  def uniq_booking_charge
    errors.add(:base, "Booking charge should be applied once") if document.booking_charges.size > 0
  end
  
  def charge_with_recurly
    begin
      charge = Recurly::Charge.create(
        :account_code => document.rental_unit.user_id,
        :amount_in_cents => cents,
        :description => "Charging $#{"%.2f" % (cents/100.0)} fee for Booking ##{document_id}",
        :start_date => document.start_date
      )
      self.transaction_id = charge.id
      self.state = 'charged'
    rescue => err
      self.state = 'error'
      self.description = err.to_s
    ensure
      self.processed_at = Time.now
      self.save(:validate => false)
    end
  end
end