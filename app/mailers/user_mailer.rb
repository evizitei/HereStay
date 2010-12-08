class UserMailer < ActionMailer::Base
  default :from => "donotreply@here-stay.com"
  
  def owner_message_notification(message)
    @message = message
    @rental_unit = message.booking.rental_unit
    owner = User.find_by_fb_user_id(message.booking.rental_unit.fb_user_id)
    if owner && owner.email
      mail(:to=>owner.email)
    end
  end
  
  def renter_message_notification(message)
    @message = message
    @rental_unit = message.booking.rental_unit
    renter = User.find_by_fb_user_id(message.booking.renter_fb_id)
    if renter && renter.email
      mail(:to=>renter.email)
    end
  end
  
  def booking_confirmation(booking)
    @booking = booking
    @rental_unit = booking.rental_unit
    renter = User.find_by_fb_user_id(@booking.renter_fb_id)
    if renter && renter.email
      mail(:to=>renter.email)
    end
  end
  
  def booking_canceled_notification(booking, fb_user_id)
    @booking = booking
    @rental_unit = booking.rental_unit
    if user = User.find_by_fb_user_id(fb_user_id)
      if user.email
        mail(:to=>user.email)
      end
    end
  end
  
  def booking_canceled_by_renter_notification(booking)
    @booking = booking
    @rental_unit = booking.rental_unit
    if owner = User.find_by_fb_user_id(@booking.owner_fb_id)
      if owner.email
        mail(:to=>owner.email)
      end
    end
  end
  
  def booking_canceled_by_owner_notification(booking)
    @booking = booking
    @rental_unit = booking.rental_unit
    if renter = User.find_by_fb_user_id(@booking.renter_fb_id)
      if renter.email
        mail(:to=>renter.email)
      end
    end
  end
end
