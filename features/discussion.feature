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
    When I wait 7 seconds
    Then I should see 1 messages

	@javascript
	Scenario: Receiving a new chat message
		Given I am logged in as the user with FB id "13579"
		And There is a booking discussion with id "7" where I am the renter
		And I am on the booking discussion page for booking 7
		When the owner of booking "7" posts the message "Stay Any Time"
		Then booking 7 should have 1 messages
		When I wait 5 seconds
		Then I should see "Stay Any Time" within ".message_body"
		
	
	Scenario: Delivering a message to an online user
	  Given I am logged in as the user with FB id "13579"
	    And there is another user with FB id "97531"
		  And There is a booking discussion with id "7" where I am the renter and "97531" is the owner
		  And the user "97531" is online
		When I send a message for booking "7" saying "I want to stay here"
		Then there should be no SMS messages sent
	
	Scenario: Delivering a message to an offline user without a phone
	  Given I am logged in as the user with FB id "13579"
	    And there is another user with FB id "97531"
		  And There is a booking discussion with id "7" where I am the renter and "97531" is the owner
		  And the user "97531" has been offline for "4" hours
		When I send a message for booking "7" saying "I want to stay here"
		Then there should be no SMS messages sent
	
	Scenario: Delivering a message to an offline user with a phone
  	  Given I am logged in as the user with FB id "13579"
  	    And there is another user with FB id "97531" and phone number "15732395840"
  		  And There is a booking discussion with id "7" where I am the renter and "97531" is the owner
  		  And the user "97531" has been offline for "4" hours
  		When I send a message for booking "7" saying "I want to stay here"
  		Then there should be an SMS sent to "15732395840" containing "You have a new message in HereStay:"

