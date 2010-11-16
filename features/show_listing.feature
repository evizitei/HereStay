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