Feature: Distributed cucumber
  In order run my cukes quickly
  As a Cucumber user
  I want to distribute my cukes

  Background: 
    Given I have a master and 2 slaves running
    And a report app is running

  Scenario: Distribute 2 features
    Given I POST the following list to the master web service:
      | feature/example1.feature |
      | feature/example2.feature |
    Then the reporter should know when the run has finished
    And I should be able to GET the results
