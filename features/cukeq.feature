Feature: Distributed cucumber
  In order run my cukes quickly
  As a Cucumber user
  I want to distribute my cukes

  Background:
    Given I have a master and 2 slaves running
    And a report app is running

  Scenario: Distribute 2 features
    When I POST the following list to the master web service:
      | features/example1.feature |
      | features/example2.feature |
    Then the report app should know when the run has finished
    And I should be able to GET the results
