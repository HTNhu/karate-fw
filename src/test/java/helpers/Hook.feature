@ignore
Feature: to demo that features can be used in an 'afterScenario' hook
    Background: Preconditions
    * print 'in "after-scenario.feature", caller:', caller, articleId
    * url apiUrl
  Scenario: Delete Article
    Given path 'articles', articleId
    When method Delete
    Then status 200


