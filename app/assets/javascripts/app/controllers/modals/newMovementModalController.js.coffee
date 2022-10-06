app.controller "newMovementModalController", [
  "$scope"
  "$modalInstance"
  "$filter"
  "Movement"
  "Shareholder"
  "currentUser"
  "people"
  "movements"
  "groups"
  "getUserName"
  "openNewContact"
  "getGroup"
  "movement_opt"
  ($scope, $modalInstance, $filter, Movement, Shareholder, currentUser, people, movements, groups, getUserName, openNewContact, getGroup, movement_opt) ->
    movementOriginal = movement_opt
    movement_opt = angular.copy(movement_opt)
    $scope.currentUser = currentUser
    $scope.people = people
    $scope.movements = movements
    $scope.groups = groups
    $scope.getUserName = getUserName
    $scope.openNewContact = openNewContact
    $scope.getGroup = getGroup
    $scope.movement = shareholders: []

    # if (movement_opt) {
    #   $scope.movement = movement_opt;
    #   $scope.movement.amount = parseFloat(movement_opt.amount);
    # }
    # $scope.movement.shareholders = movement_opt ? movement_opt.shareholders : [];
    # $scope.movement.shareholders_attributes = $scope.movement.shareholders;
    # $scope.movement.type = $scope.movement.receiverId != null ? 'transfer' : $scope.isEdit ? 'movement' : false;
    # $scope.isEdit = movement_opt != null;
    $scope.formState = "type"
    $scope.allSelected = shareholders: false
    $scope.form = newmovement: null


    ###
    Add/remove a user as shareholders of the movement.
    @param  {User} user User object.
    ###
    $scope.toggleShareholder = (user) ->
      shareholder = _.findWhere($scope.movement.shareholders, userId: user.userId )

      if shareholder
        if shareholder.isPayer
          shareholder.isReceiver = not shareholder.isReceiver
        else
          idx = $scope.movement.shareholders.indexOf(shareholder)
          $scope.movement.shareholders.splice(idx, 1)
      else
        $scope.movement.shareholders.push(new Shareholder
          userId: user.userId
          isPayer: false
          isReceiver: true)
      $scope.checkShareholdersSelectStatus()


    ###
    Add shareholder to the current new movement.
    @param {User} user User object.
    ###
    $scope.addShareholder = (user, options) ->
      shareholder = _.findWhere($scope.movement.shareholders, userId: user.userId )
      options = options or {}

      unless shareholder
        $scope.movement.shareholders.push(new Shareholder
          userId: user.userId
          isPayer: (if typeof options.isPayer isnt "undefined" then options.isPayer else false)
          isReceiver: (if typeof options.isReceiver isnt "undefined" then options.isReceiver else true))
      else
        shareholder.isReceiver = true
      $scope.checkShareholdersSelectStatus()
      return


    ###
    Add/remove all contacts as shareholders.
    ###
    $scope.toggleAllShareholders = ->
      if $scope.allSelected.shareholders
        $scope.selectAllShareholders()
      else
        $scope.unselectAllShareholders()


    $scope.selectAllShareholders = -> 
      possibleUsers = $filter("inGroup")($scope.getPeople(), $scope.getGroup($scope.movement.groupId))
      # Select all
      _.each possibleUsers, (user) ->
        shareholder = _.findWhere($scope.movement.shareholders, userId: user.userId )
        unless shareholder
          $scope.movement.shareholders.push(new Shareholder
            userId: user.userId
            isPayer: false
            isReceiver: true
          )
        else
          shareholder.isReceiver = true
      $scope.checkShareholdersSelectStatus()


    $scope.unselectAllShareholders = ->
      # Unselect all
      $scope.movement.shareholders.splice(0, $scope.movement.shareholders.length)
      $scope.checkShareholdersSelectStatus()


    ###
    Is the user shareholder of current new movement?
    @param  {User}  user User.
    @return {Boolean}
    ###
    $scope.isShareholder = (user) ->
      _.findWhere($scope.movement.shareholders,
        userId: user.userId
        isReceiver: true
      )?


    $scope.checkShareholdersSelectStatus = ->
      $scope.allSelected.shareholders = $scope.movement.shareholders.length is $filter("inGroup")($scope.getPeople(), $scope.getGroup($scope.movement.groupId)).length


    ###
    Dismiss popup.
    ###
    $scope.cancel = ->
      $modalInstance.dismiss "cancel"


    ###
    Save movement.
    @param  {Movement} movement New movement object.
    ###
    $scope.save = (movement) ->
      if $scope.form.newmovement.$valid
        # Mark shareholder as payer.
        payer = _.findWhere(movement.shareholders, userId: movement.payerId )
        payer.isPayer = true
        movement.shareholders_attributes = movement.shareholders
        new Movement(movement).save().then (movement) ->
          $modalInstance.close(movement)


    ###
    Go to form state.
    @param  {string} state
    ###
    $scope.goTo = (state) ->
      $scope.movement.error = ""
      if state is "type"
        $scope.movement.type = null
        $scope.movement.groupId = null
        $scope.movement.payerId = null
        $scope.movement.shareholders.splice(0, $scope.movement.shareholders.length)
        $scope.movement.shareholdersDone = false
      if state is "group"
        $scope.movement.groupId = null
        $scope.movement.payerId = null
        $scope.movement.shareholders.splice(0, $scope.movement.shareholders.length)
        $scope.movement.shareholdersDone = false
      if state is "payer"
        $scope.movement.payerId = null
        $scope.movement.shareholders.splice(0, $scope.movement.shareholders.length)
        $scope.movement.shareholdersDone = false
      if state is "shareholders"
        $scope.movement.shareholders.splice(0, $scope.movement.shareholders.length)
        $scope.movement.shareholdersDone = false
      $scope.setState()


    ###
    Select a type of movement.
    @param  {string} type Values: expense | transfer
    ###
    $scope.selectMovementType = (type) ->
      $scope.movement.type = type
      $scope.selectMovementGroup false if $scope.groups.length is 0
      $scope.setState()


    ###
    Select if its a personal movement or if it belongs to a group.
    @param  {Group} group Group.
    ###
    $scope.selectMovementGroup = (group) ->
      $scope.movement.groupId = (if group then group.id else false)
      if $scope.movement.type is "expense"
        # By default add all members of the group to the expense, becos is the common scenario
        if group
          _.each group.users, (member) ->
            # Shareholder expects users, not members of groups
            $scope.addShareholder _.findWhere($scope.getPeople(), userId: member.userId)
        # By default, and only current user to the expense, cos he's almost certainly going to be a part of it.
        else
          $scope.addShareholder currentUser
      $scope.setState()


    $scope.getPeople = ->
      if $scope.movement.groupId
        $scope.getGroup($scope.movement.groupId).users
      else
        $scope.people


    $scope.getGroup = (id) ->
      _.findWhere($scope.groups, id: id)


    ###
    Select who paid.
    @param  {User} person User.
    ###
    $scope.selectMovementPayer = (person) ->
      $scope.movement.payerId = person.userId
      $scope.addShareholder(person,
        isReceiver: false
        isPayer: true)
      $scope.setState()


    ###
    Select the shareholders of the movement.
    If the movement belongs to a gruop, currentUser can not be present.
    If the movement is personal, currentUser have to be involved.
    @param  {array} shareholders Enjoyers of the movement. Array of User.
    ###
    $scope.selectMovementShareholders = (shareholders) ->
      unless $scope.movement.groupId
        if $scope.movement.payerId isnt currentUser.userId and not _.findWhere(shareholders, userId: currentUser.userId)
          $scope.movement.error = "notinvolved"
          return
      $scope.movement.error = ""
      $scope.movement.shareholdersDone = true
      $scope.setState()


    ###
    Change state depending on movement selection.
    ###
    $scope.setState = ->
      $scope.formState = "type"
      if $scope.movement.type
        $scope.formState = "group"
      else
        return
      if $scope.movement.groupId?
        $scope.formState = "payer"
      else
        return
      if $scope.movement.payerId
        $scope.formState = "shareholders"
      else
        return
      $scope.formState = "details"  if $scope.movement.shareholdersDone
]