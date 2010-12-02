class Mobile::MessagesController < MessagesController
  layout 'mobile'
  defaults :resource_class => BookingMessage, :collection_name => 'booking_messages', :instance_name => 'booking_message'
end