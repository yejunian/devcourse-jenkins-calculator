Feature: Calculator
  Scenario: Sum two numbers
    Given I have two numbers: 2 and 3
    When the calculator sums them
    Then I receive 5 as a result
