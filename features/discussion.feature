Feature: Basic Discussion
  As a user
  I want to send messages to other users about properties
  In order to book/promote those units

#  	Scenario: Posting a new message
#		Given I am the user with FB id "13579"
#		And There is a booking discussion with id "7"
#		When FB User "13579" posts "I want to stay here" to the chat for booking "7"
#		Then there should be a new chat saying "I want to stay here"
#		And I should get a JSON chat back saying "I want to stay here"

	@javascript
	Scenario:  Posting a chat message from the form
		Given I am logged in as the user with FB id "13579"
		And There is a booking discussion with id "7" where I am the renter
		And I am on the booking discussion page for booking 7
               	When I fill in "booking_message_message" with "I want to stay here"
                And I press "Send Message"
                Then I should see "I want to stay here" within ".message_body"

	@javascript
	Scenario: Receiving a new chat message
		Given I am logged in as the user with FB id "13579"
		And There is a booking discussion with id "7" where I am the renter
		And I am on the booking discussion page for booking 7
		When the owner of booking "7" posts the message "Stay Any Time"
		Then booking 7 should have 1 messages
		When I wait 5 seconds
		Then I should see "Stay Any Time" within ".message_body"

