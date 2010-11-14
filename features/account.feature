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