app.controller "newContactController", [
  "$scope"
  "$modalInstance"
  "$compile"
  "$q"
  "Contact"
  "currentUser"
  "GoogleContacts"
  "$timeout"
  ($scope, $modalInstance, $compile, $q, Contact, currentUser, GoogleContacts, $timeout) ->
    $scope.googleContacts = []
    $scope.alreadyRegistered = []
    $scope.allContacts = []
    $scope.contactsLoading = true
    $scope.stForm = searchText: ""
    
    # Set small timeout so the modal appears smoothly
    $timeout (->
      # Get google contacts
      GoogleContacts.query().then (results) ->
        $scope.googleContacts = angular.copy(results)
        
        # Remove myself
        currentUserG = _.findWhere($scope.googleContacts, address: currentUser.email)
        $scope.googleContacts.splice($scope.googleContacts.indexOf(currentUserG), 1)
        emails = _.pluck($scope.googleContacts, "address")
        
        # Get already registered google contacts
        Contact.checkRegistered(emails).then (results) ->
          Array::push.apply($scope.alreadyRegistered, results)
          
          # Delete already registered form google contacts
          angular.forEach $scope.alreadyRegistered, (contact) ->
            user = _.findWhere($scope.googleContacts, address: contact.email)
            $scope.googleContacts.splice($scope.googleContacts.indexOf(user), 1)
          
          # Mix all contacts
          $scope.allContacts = $scope.alreadyRegistered.concat($scope.googleContacts)
          $scope.contactsLoading = false
    ), 300


    $scope.isContact = (contact) ->
      _.findWhere($scope.contacts, userId: contact.userId)


    $scope.addContact = (contact) ->
      new Contact([contact]).create().then (contact) ->
        $modalInstance.close(contact)


    $scope.sendInvitation = (email) ->
      new Contact([email: email]).create().then (contact) ->
        $modalInstance.close(contact)


    $scope.cancel = ->
      $modalInstance.dismiss "cancel"
]