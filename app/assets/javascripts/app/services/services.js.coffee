
# Este servicio está asi repetido (ver User) porque no devuelve un promise
# correcto que luego es resuelto como el de angular, asi que no puedo
# usarlo bien a menos que llene todo de 'then's, Utilizo este para updatar
# el user y el de resource de angular para hacer el GET
app
  .factory("RailsUser", [
    "railsResourceFactory"
    (railsResourceFactory) ->
      return railsResourceFactory
        url: "api/users"
        name: "user"
        interceptors: ["loadingRailsInterceptor"]

  ]).factory("User", [
    "$resource"
    ($resource) ->
      return $resource("api/users/:userId", {})

  ]).factory("currentUser", [
    "User"
    (User) ->
      return User.get()

  ]).factory("Shareholder", [
    "railsResourceFactory"
    (railsResourceFactory) ->
      return railsResourceFactory
        url: "api/shareholders"
        name: "shareholder"
        interceptors: ["loadingRailsInterceptor"]

  ]).factory("Movement", [
    "railsResourceFactory"
    "railsSerializer"
    (railsResourceFactory, railsSerializer) ->
      return railsResourceFactory
        url: "api/movements"
        name: "movement"
        interceptors: ["loadingRailsInterceptor"]
        serializer: railsSerializer(->
          @nestedAttribute "shareholders"
          @exclude "payerId", "error", "shareholdersDone")

  ]).factory("Contact", [
    "railsResourceFactory"
    (railsResourceFactory) ->
      resource = railsResourceFactory
        url: "api/contacts"
        name: "contact"
        interceptors: ["loadingRailsInterceptor"]
      resource.checkRegistered = (emails) ->
        resource.$post "/api/contacts/check_registered",
          emails: emails
      return resource

  ]).factory("Group", [
    "railsResourceFactory"
    (railsResourceFactory) ->
      return railsResourceFactory
        url: "api/groups"
        name: "group"
        interceptors: ["loadingRailsInterceptor"]

  ]).factory "socket", ->
    faye = new Faye.Client("http://" + location.hostname + ":9292/faye")
