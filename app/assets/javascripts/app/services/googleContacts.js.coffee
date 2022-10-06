app.factory "GoogleContacts", ['$q', ($q) ->
  service = {}
  googleContactsDeferred = $q.defer()
  apiKey = "00820ef4ea7fae564f79c9ccfbe0a72f5e3d2259"
  
  if location.hostname.match 'localhost'
    clientId = "796900560159-nn66000ojcbmrultj0g0mj2bdb4trfpg.apps.googleusercontent.com"
  else 
    clientId = '796900560159-t0rm3dtpcghp6s4ljbntv4qhmlq1cb39.apps.googleusercontent.com'

  scopes = "https://www.google.com/m8/feeds"

  service.query = ->
    gapi.client.setApiKey apiKey
    gapi.auth.authorize
      client_id: clientId
      scope: scopes
      immediate: false
    , (authResult) ->
      if authResult and not authResult.error
        contactsFeedUri = "/m8/feeds/contacts/default/full"
        gapi.client.request(
          path: contactsFeedUri
          params:
            alt: "json"
            "max-results": 600
        ).execute (response) ->
          emails = []
          _.each response.feed.entry, (item) ->
            _.each item.gd$email, (emailItem) ->
              emailItem.name = item.title.$t
              emails.push(emailItem)
          googleContactsDeferred.resolve(emails)
    googleContactsDeferred.promise
  service
]