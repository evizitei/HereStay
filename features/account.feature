Feature: Editing my account
  As a user
  I want to be able to edit my account
  In order to update my phone number and other info
  
  Scenario: updating my phone number
    Given I am logged in as the user with FB id "13579"
      And I am on the my account page
    When I follow "Edit Account"  
      And I fill in "Phone" with "15732395840"
      And I press "Save"
    Then my phone number should be "15732395840"
    
  Scenario: update my phone timebox
    Given I am logged in as the user with FB id "13579"
      And I am on the my account page
    When I follow "Edit Account"
      And I select "07" from "user[sms_starting_at(4i)]"
      And I select "17" from "user[sms_ending_at(4i)]"
      And I press "Save"
    Then I should be available by phone at "8:00 AM"
      And I should not be available by phone at "6:00 PM"