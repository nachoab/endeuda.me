app.controller "baseController", [
  "$scope"
  "$modal"
  "$state"
  "currentUser"
  "RailsUser"
  "Movement"
  "Contact"
  "Group"
  "$q"
  ($scope, $modal, $state, currentUser, RailsUser, Movement, Contact, Group, $q) ->

    contactPromise = Contact.query()
    groupPromise = Group.query()
    movementPromise = Movement.query()

    $scope.currentUser = currentUser
    $scope.debtList = null
    $scope.movements = null

    $scope.movementsTypes = [
      {
        value: "all"
        typeName: "All movements"
      }
      {
        value: "isPayer"
        typeName: "Expenses paid"
      }
      {
        value: "isShareholder"
        typeName: "Expenses enjoyed"
      }
      {
        value: "isTransferer"
        typeName: "Transfers sent"
      }
      {
        value: "isReceiver"
        typeName: "Transfers received"
      }
    ]

    $scope.movementFilter =
      userId: null
      type: $scope.movementsTypes[0].value
      typeName: $scope.movementsTypes[0].typeName
      group: null

    $scope.movementFilter.updateTypeName = ->
      _.find $scope.movementsTypes, (obj) ->
        $scope.movementFilter.typeName = obj.typeName  if $scope.movementFilter.type is obj.value

    $q.all([
      contactPromise
      groupPromise
      movementPromise
    ]).then (results) ->
      $scope.contacts = results[0] or []
      $scope.groups = results[1] or []
      $scope.movements = results[2] or []
      $scope.updateAggregatedLists()

    $scope.updateAggregatedLists = ->
      $scope.debtList = $scope.contacts.concat($scope.groups)
      $scope.people = $scope.contacts.concat([currentUser])


    ###
    Gets currentUser total debt in one group.
    @param  {Group} group            Group object.
    @param  {array} movements        Array of Movements where to count.
    @param  {boolean?} opt_positive  Si es true devuelve un número entero.
    @return {number}                 Total.
    ###
    $scope.getGroupDebt = (group, movements, opt_positive) ->
      debt = "?"
      debt = $scope.getUserBalanceInGroup(currentUser, group, movements, opt_positive) if movements
      debt


    ###
    Returns my total debt with all users and groups combined.
    @return {number|string} Float 2 digits or ? if not available.
    ###
    $scope.getMyTotalDebt = ->
      total = "?"
      if $scope.movements
        # Contacts debt
        total = _.reduce($scope.contacts, (memo, contact) ->
          # Negative debt means he owe me
          memo - parseFloat($scope.getUserDebtWithMe(contact, $scope.movements))
        , 0)
        
        # Groups debts
        total += _.reduce($scope.groups, (memo, group) ->
          # Negative debt means I have a negative balance, so I owe
          memo + parseFloat($scope.getUserBalanceInGroup(currentUser, group, $scope.movements))
        , 0)
      total


    ###
    Gets the total expense sum of a group.
    @param  {Group} group     Group object.
    @return {string|number}   Float 2 digits amount or ? if not available.
    ###
    $scope.getGroupTotalExpenses = (group) ->
      total = "?"
      if $scope.movements
        movements = _.filter($scope.movements, (movement) -> movement.groupId is group.id)

        total = (if movements then _.reduce(_.pluck(_.where(movements,
          type: "expense"
        ), "amount"), (memo, num) ->
          memo + parseFloat(num)
        , 0).toFixed(2) else "?")
      total


    ###
    Returns the amount a user has spend in a group.
    @param  {object} user          User object.
    @param  {object} group         Group object.
    @param  {array} movements      Movement object array.
    @param  {boolean} opt_positive Returns a positive value.
    @return {string|number}   Float 2 digits amount or ? if not available.
    ###
    $scope.getUserExpenseInGroup = (user, group, movements, opt_positive) ->
      total = "?"
      if movements
        total = 0
        _.each movements, (movement) ->
          # Filter group, only expenses
          if movement.groupId is group.id and movement.type is "expense"
            # If is shareholder
            total += $scope.getShareholdersShare(movement) if _.findWhere(movement.shareholders,
              userId: user.userId
              isReceiver: true)
        total = total.toFixed(2)
      total


    ###
    Get user balance in a group.
    @param  {object}  user            User object.
    @param  {object}  group           Group object.
    @param  {array}   movements       Array of movements.
    @param  {boolean} opt_positive    Returns a positive number.
    @return {string|number}           Float 2 digits amount or ? if not available.
    ###
    $scope.getUserBalanceInGroup = (user, group, movements, opt_positive) ->
      total = "?"
      if movements
        total = 0
        _.each movements, (movement) ->
          # Filter group movements
          if movement.groupId is group.id
            amount = parseFloat(movement.amount)
            share = $scope.getShareholdersShare(movement)
            _.each movement.shareholders, (shareholder) ->
              if shareholder.userId is user.userId
                total -= share  if shareholder.isReceiver
                # There will only be one payer.
                # There could be more than one, and share the pay. TODO
                total += amount  if shareholder.isPayer
        total = total.toFixed(2)
      (if opt_positive then Math.abs(total) else total)


    ###
    Get how much we owe each other.
    @param  {User}    user            User object.
    @param  {array}   movements       Array of movements.
    @param  {boolean} opt_positive    Returns a positive number.
    @return {string|number}           Float 2 digits amount or ? if not available.
    ###
    $scope.getUserDebtWithMe = (user, movements, opt_positive) ->
      total = "?"
      if movements
        total = 0
        _.each movements, (movement) ->
          unless movement.groupId
            heShareholder = _.findWhere(movement.shareholders, userId: user.userId)
            meShareholder = _.findWhere(movement.shareholders, userId: currentUser.userId)
            # One of us has to be payers
            userAccountsForMovement = heShareholder and meShareholder and (heShareholder.isPayer or meShareholder.isPayer)
            if userAccountsForMovement
              # As payer sums
              total += parseFloat(movement.amount)  if heShareholder.isPayer
              # As recipent subtract share
              total -= $scope.getShareholdersShare(movement)  if heShareholder.isReceiver
        total = total.toFixed(2)
      (if opt_positive then Math.abs(total) else total)


    ###
    Returns how much each user has spent in a movement.
    @param  {object} movement Movement object.
    @return {number}          Share amount.
    ###
    $scope.getShareholdersShare = (movement) ->
      parseFloat(movement.amount) / _.where(movement.shareholders, isReceiver: true).length


    ###
    Open modal new movement.
    @param  {object?} movement_opt Movement object, if defined edit.
    ###
    $scope.newMovement = (movement_opt) ->
      if $scope.groups and $scope.people
        modalInstance = $modal.open
          template: JST["modals/new_movement_modal"]()
          resolve:
            people: ->
              $scope.people
            movements: ->
              $scope.movements
            groups: ->
              $scope.groups
            getUserName: ->
              $scope.getUserName
            openNewContact: ->
              $scope.openNewContact
            getGroup: ->
              $scope.getGroup
            movement_opt: ->
              movement_opt
          controller: "newMovementModalController"
        modalInstance.result.then (movement) ->
          $scope.movements.push movement
          $scope.movements.timestamp = new Date().getTime()


    ###
    Open modal new group.
    ###
    $scope.newGroup = (opt_group) ->
      if $scope.people
        modalInstance = $modal.open(
          template: JST["modals/new_group_modal"]()
          resolve:
            people: ->
              $scope.people
            contacts: ->
              $scope.contacts
            groups: ->
              $scope.groups
            getUserName: ->
              $scope.getUserName
            openNewContact: ->
              $scope.openNewContact
            editableGroup: ->
              opt_group
          backdrop: "static"
          controller: "newGroupController"
        )
        modalInstance.result.then (group) ->
          # It was an edition
          if opt_group
            group = _.findWhere($scope.groups, id: opt_group.id)
            $scope.groups[$scope.groups.indexOf(group)] = group
          # It was a new one
          else
            $scope.groups.push(group)
          $scope.updateAggregatedLists()


    ###
    Open modal new contact.
    ###
    $scope.newContact = ->
      modalInstance = $modal.open
        template: JST["modals/new_contact_modal"]()
        scope: $scope
        backdrop: "static"
        controller: "newContactController"

      modalInstance.result.then (contacts) ->
        _.each contacts, (contact) ->
          $scope.contacts.push(contact)
        $scope.updateAggregatedLists()

    $scope.addMemberToGroup = (group) ->
      $scope.newGroup(group)


    ###
    Destroy movement.
    @param  {object} movement Movement object.
    ###
    $scope.destroy = (movement) ->
      movement.remove().then (item) ->
        $scope.movements.splice($scope.movements.indexOf(item), 1)

    $scope.edit = (movement) ->
      $scope.addMovement(movement)

    $scope.movementFilterComparator = (actual, expected) ->
      (if expected then angular.equals(expected, actual) else true)

    $scope.selectContact = (contact) ->
      $scope.movementFilter.userId = (if $scope.movementFilter.userId is contact.userId then null else contact.userId)
      if $scope.movementFilter.userId
        $scope.movementFilter.type = "all"  unless $scope.movementFilter.type
        $scope.showFilter = true
      else
        $scope.showFilter = false

    $scope.closeDropdown = ->
      document.getElementsByTagName("html")[0].click()

    $scope.getShareholdersNames = (shareholders) ->
      if shareholders.length
        _.map(shareholders, (shareholder) ->
          contact = $scope.getContact(shareholder.userId)
          (if contact then contact.name or contact.email else "")
        ).join ", "
      else
        ""

    ###
    Gets user by its id.
    @param  {number} userId User id.
    @return {object?}        User object.
    ###
    $scope.getUser = (userId) ->
      _.findWhere($scope.people, userId: userId) if $scope.people

    $scope.getPayer = (movement) ->
      _.findWhere(movement.shareholders, isPayer: true)


    ###
    Find an user a return its name.
    @param  {number} id               UserId.
    @param  {boolean} opt_minimalist  Trim from first space.
    @return {string?}                 Name.
    ###
    $scope.getUserName = (id, opt_minimalist) ->
      if $scope.people
        person = $scope.getUser(id)
        (if person and person.email then (person.name or person.email.replace(/@.*/, "")).replace((if opt_minimalist then /\s.*/ else ""), "") else null)


    ###
    Search group.
    @param  {number} id Id.
    @return {Group}     Group object.
    ###
    $scope.getGroup = (id) ->
      _.findWhere($scope.groups, id: id)


    ###
    Change user name.
    ###
    $scope.changeName = ->
      new RailsUser($scope.currentUser).update().then (user) ->
        # Hay que pedirlo otra vez por como estÃ¡ hecho el servicio
        currentUser.$get()


    ###
    Gets all different months in all movements.
    @param  {array} movements Array of Movement.
    @return {array}           Array of number.
    ###
    $scope.getMonthsInMovements = (movements) ->
      months = []
      dates = []
      _.each movements, (movement) ->
        month = moment(movement.createdAt).format("M")
        if months.indexOf(month) is -1
          months.push month
          dates.push movement.createdAt
      dates
]