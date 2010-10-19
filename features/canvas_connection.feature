Feature: Basic level facebook integration
  As a Property Owner
  I want to have access to the application on facebook
  So that I can list my properties where my friends can see them so I'll make rental income
  
  Scenario: Facebook directory canvas call
    When I go to the canvas directory
    Then I should see "Mi Casa Su Casa"
  
  Scenario: Nonfacebook canvas call
    When I go to the canvas asset
    Then I should see "Mi Casa Su Casa"