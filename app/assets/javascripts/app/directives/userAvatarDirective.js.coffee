app.directive "userAvatar", [
  "$q"
  "$cacheFactory"
  ($q, $cacheFactory) ->
    cache = $cacheFactory("avatars")

    return (
      restrict: "EA"
      scope:
        user: "=user"
      link: ($scope, element, attrs) ->
        colors = [
          "#f9b800"
          "#000000"
          "#f78988"
          "#7dc5f3"
          "#81cd8e"
          "#9d83bf"
          "#2b4c70"
          "#363b47"
          "#e2008f"
          "#1e5b9e"
          "#a51800"
          "#d15400"
        ]
        user = $scope.user
        getAvatarUrl = (user) ->
          return element.html(cache.get(user.userId)) if cache.get(user.userId)
          user.avatar

        preloadImage = (src) ->
          deferred = $q.defer()
          image = new Image()

          unless src
            deferred.reject()
            return deferred.promise
          unless typeof cache.get(src) is "undefined"
            if cache.get(src)
              deferred.resolve src
            else
              deferred.reject()
            return deferred.promise

          image.onerror = ->
            cache.put src, false
            deferred.reject()
            return

          image.onload = ->
            cache.put src, true
            deferred.resolve src
            return

          image.src = src
          deferred.promise

        preloadImage(getAvatarUrl(user)).then ((src) ->
          element.html "<img src=\"" + src + "\"/>"
          return
        ), ->
          character = (user.name or user.address or user.email or "").match(/\w/) or [""]
          color = colors[character[0].charCodeAt(0) % colors.length]
          element.html "<div style=\"background:" + color + "\" id=\"" + element[0].id + "\" class=\"st-navbar-alternative-avatar " + element[0].className + "\"><div class=\"envelope\"><span>" + character + "</span></div></div>"
    )
]