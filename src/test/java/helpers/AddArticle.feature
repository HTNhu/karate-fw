Feature: Add Article

  Scenario: Create a new article
    Given url apiUrl
    Given path 'articles'
    And request {"article": {"tagList": [],"title": "#(articleName)","description": "des","body": "body"}}
    When method Post
    Then status 200
    And match response.article.title == '#(articleName)'


