app.controller('newGroupController', ['$scope', '$modalInstance', 'Group', 'currentUser', 'people', 'contacts', 'groups', 'getUserName', 'openNewContact', 'editableGroup',
  function($scope, $modalInstance, Group, currentUser, people, contacts, groups, getUserName, openNewContact, editableGroup) {
    $scope.currentUser = currentUser;
    $scope.contacts = editableGroup ? people : contacts;
    $scope.groups = groups;
    $scope.getUserName = getUserName;
    $scope.openNewContact = openNewContact;
    $scope.group = editableGroup || {users: [], name: ''};
    $scope.isEdit = editableGroup != null;
    $scope.usersAdded = [];

    $scope.toggleMember = function (contact) {
      var contactFound = _.findWhere($scope.group.users, {userId: contact.userId});

      if (contactFound) {
        $scope.group.users.splice($scope.group.users.indexOf(contactFound), 1);
        $scope.usersAdded.splice($scope.usersAdded.indexOf(contact), 1);
      } else {
        $scope.group.users.push(contact);
        $scope.usersAdded.push(contact);
      }
    };

    $scope.isMember = function (contact) {
      return _.findWhere($scope.group.users, { 'userId': contact.userId }) != null;
    };

    $scope.toggleAll = function () {
      var groupUsersLength = $scope.group.users.length;
      $scope.group.users = [];

      if (groupUsersLength != $scope.contacts.length) {
        angular.forEach($scope.contacts, function (contact) {
          $scope.group.users.push(contact);
        });
      }
    };

    $scope.save = function (group) {
      if (group.users.length < 1) {
        $scope.group.error = 'notenoughmembers';
      } else if (group.form.name.$error.required) {
        $scope.group.error = 'groupname';
      } else if ($scope.group.form.$valid) {
        new Group(group).save().then(function(group) {
          $modalInstance.close(group);
        });
      }
    };

    $scope.cancel = function () {
      _.each(angular.copy($scope.usersAdded), function(user) {
        $scope.toggleMember(user);
      });
      $modalInstance.dismiss('cancel');
    };

  }]);