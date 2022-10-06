###
Filter movements by type and user
@param  {array}  movements Array of Movement.
@param  {object} filter    Type: isPayer, isShareholder, isReceiver, isTransferer, userId: user selected (can be null).
@return {array}            Array of Movements
###
app.filter "filterMovements", ->
  (movements, filter) ->
    if filter
      filterUserId = filter.userId
      filterType = filter.type
      filterGroup = filter.group
      
      # Only movements of this group
      if filterGroup
        movements = _.filter movements, (movement) -> movement.groupId is filterGroup.id
      # Only movements not in groups if filter by user
      else if filterUserId
        movements = _.filter movements, (movement) -> not movement.groupId?


      # Expenses paid by user
      if filterUserId > 0 and filterType is "isPayer"
        _.filter movements, (movement) ->
          (if movement.type is "expense" and _.findWhere(movement.shareholders,
            userId: filterUserId
            isPayer: true
          ) then movement)
      

      # Expenses enjoyed by user
      else if filterUserId > 0 and filterType is "isShareholder"
        _.filter _.map(movements, (movement) ->
          (if movement.type is "expense" and _.findWhere(movement.shareholders,
            userId: filterUserId
            isReceiver: true
          ) then movement else false)
        ), (item) ->
          item isnt false

      
      # Transfer received by user
      else if filterUserId > 0 and filterType is "isReceiver"
        _.filter _.map(movements, (movement) ->
          (if movement.type is "transfer" and _.findWhere(movement.shareholders,
            userId: filterUserId
            isReceiver: true
          )? then movement else false)
        ), (item) ->
          item isnt false

      
      # Transfer made by user
      else if filterUserId > 0 and filterType is "isTransferer"
        _.filter _.map(movements, (movement) ->
          (if movement.type is "transfer" and _.findWhere(movement.shareholders,
            userId: filterUserId
            isPayer: true
          )? then movement else false)
        ), (item) ->
          item isnt false

      
      # All movements a user is involved in
      else if filterUserId and filterType is "all"
        _.filter movements, (movement) ->
          _.findWhere(movement.shareholders,
            userId: filterUserId
            isReceiver: true
          )? or _.findWhere(movement.shareholders,
            userId: filterUserId
            isPayer: true
          )?

      
      # All transfers
      else if not filterUserId and (filterType is "isReceiver" or filterType is "isTransferer")
        _.filter _.map(movements, (movement) ->
          (if movement.type is "transfer" then movement else false)
        ), (item) -> item isnt false

      
      # All movements
      else
        movements
