Feature: listing display page
  As a user
  I want to look at a listing
  In order to decide whether I want to book it
  
  Scenario: listing with an online owner
    Given there is a unit named "Death Star" with owner "23456"
      And the user "23456" is online
    When I go to the listing for "Death Star"
    Then I should see "The owner is online!"
  
  Scenario: listing with an offline owner
    Given there is a unit named "Death Star" with owner "23456"
      And the user "23456" has been offline for "6" hours
    When I go to the listing for "Death Star"
    Then I should see "The owner is offline."
    
  Scenario: listing with an offline owner
    Given there is a unit named "Death Star" with owner "23456"
      And the user "23456" has the phone number "15732395840"
      And it currently is "2:00 PM"
      And the user "23456" has been offline for "6" hours
      And the user "23456" should not be online
      And the user "23456" should be available by phone
    When I go to the listing for "Death Star"
    Then I should see "The owner is available by phone."
    And return to the present