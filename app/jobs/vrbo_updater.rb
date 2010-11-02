class VrboUpdater
  def initialize(reservation_id, options = {})
    @reservation_id = reservation_id

    @action = options[:action]
    @remote_id = options[:remote_id]
    @remote_login = options[:login]
    @remote_password = options[:password]
    @remote_listing_id = options[:listing_id]
  end

  def perform
    case @action.to_sym
    when :create
      reservation.create_on_remote_server
    when :update
      reservation.update_on_remote_server
    when :destroy
      VrboReservation.destroy_reservation(@remote_login, @remote_password, @remote_listing_id, @remote_id)
    end
  end
  
  def reservation
    Reservation.find(@reservation_id)
  end
end