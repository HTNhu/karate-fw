@debug
Feature: Validate favorite and comment function

  Background: Preconditions
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * def isTimeValidator = read('classpath:helpers/TimeValidator.js')
    * url apiUrl
    * def randomArticleName = dataGenerator.getRandomArticleName()
    * call read('classpath:helpers/AddArticle.feature'){articleName: "#(randomArticleName)"}
    * def slugId = response.article.slug
    * configure afterScenario =
"""
function(){
  karate.log('after scenario:', karate.scenario.name);
  karate.call('classpath:helpers/Hook.feature', { caller: karate.feature.fileName, articleId: slugId });
}
"""
  Scenario: Favorite articles
          # Step 1: Add new article (optimize here - Create a AddArticle.feature)
#    * def randomArticleName = dataGenerator.getRandomArticleName()
#    * call read('classpath:helpers/AddArticle.feature'){articleName: "#(randomArticleName)"}
        # Step 2: Get the favorites count and slug ID for the the article, save it to variables
    * def initFavoritesCount = response.article.favoritesCount
#    * def slugId = response.article.slug
        # Step 3: Make POST request to increase favorites count for the article
    Given path 'articles', slugId, 'favorite'
    When method Post
    Then status 200
        # Step 4: Verify response schema
    And match response.article == {
    """
      "slug": "#string",
      "title": "#string",
      "description": "#string",
      "body": "#string",
      "createdAt": "#? isTimeValidator(_)",
      "updatedAt": "#? isTimeValidator(_)",
      "tagList": "#array",
      "author": {
        "username": "#string",
        "bio": "##string",
        "image": "#string",
        "following": '#boolean'
      },
      "favoritesCount": '#number',
      "favorited": '#boolean'
      }
  """
        # Step 5: Verify that favorites article incremented by 1
    * print response
        * match response.article.favoritesCount == initFavoritesCount + 1
        # Step 6: Get all favorite articles
    Given path 'articles'
    And param favorited = username
    When method Get
    Then status 200
        # Step 7: Verify response schema
    And match each response..username == username
    And match each response..favorited == true
    And match each response.articles ==
        """
            {
                "slug": "#string",
                "title": "#string",
                "description": "#string",
                "body": "#string",
                "createdAt": "#? isTimeValidator(_)",
                "updatedAt": "#? isTimeValidator(_)",
                "tagList": "#array",
                "author": {
                    "username": "#string",
                    "bio": "##string",
                    "image": "#string",
                    "following": '#boolean'
                },
                "favoritesCount": '#number',
                "favorited": '#boolean'
            }
        """
        # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
    * print response
    And match response.articles contains deep { slug: '#(slugId)' }
        # Step 9: Delete the article (optimize here with afterScenario - create a Hook.feature)

  Scenario: Comment articles
        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
#    * def randomArticleName = dataGenerator.getRandomArticleName()
#    * call read('classpath:helpers/AddArticle.feature'){articleName: "#(randomArticleName)"}
        # Step 2: Get the slug ID for the article, save it to variable
#    * def slugId = response.article.slug
        # Step 3: Make a GET call to 'comments' end-point to get all comments
    Given path 'articles', slugId, 'comments'
    When method Get
    Then status 200
        # Step 4: Verify response schema
    And match response.comments == '#array'
        # Step 5: Get the count of the comments array length and save to variable
    * def responseWithComments = response.comments
    * def commentsCount = responseWithComments.length
        # Step 6: Make a POST request to publish a new comment
    * def randomComment = dataGenerator.getRandomComment()
    Given path 'articles', slugId, 'comments'
    And request {"comment": {"body": '#(randomComment)'}}
    When method Post
    Then status 200
        # Step 7: Verify response schema that should contain posted comment text
    * def commentId = response.comment.id
    And match response.comment.body == randomComment
        # Step 8: Get the list of all comments for this article one more time
    Given path 'articles', slugId, 'comments'
    When method Get
    Then status 200
        # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
    * def commentAddLength = response.comments.length
    And match commentAddLength == commentsCount + 1
        # Step 10: Make a DELETE request to delete comment
    Given path 'articles',slugId, 'comments', commentId
    When method Delete
    Then status 200
        # Step 11: Get all comments again and verify number of comments decreased by 1
    Given path 'articles', slugId, 'comments'
    When method Get
    Then status 200
    * def commentDeleteLength = response.comments.length
    And match commentDeleteLength == commentAddLength - 1
        # Step 12: Delete the article (optimize here with afterScenario - create a Hook.feature)