app.controller('facebookContactsController', [
  '$scope',
  '$FB',
  'currentUser',
  function($scope, $FB, currentUser) {
    $scope.itemsPerPage = 8;
    $scope.currentPage = 1;
    $scope.filter = { text: '' };

    var updateLoginStatus = function (callback) {
      $FB.getLoginStatus(function (res) {
        $scope.loginStatus = res;
        (callback || angular.noop)();
      });
    };

    var updateApiMe = function (callback) {
      $FB.api('/me', function (res) {
        $scope.apiMe = res; 
        (callback || angular.noop)();
        $scope.getFacebookContacts();
      });
    };

    var login = function(callback) {
      $FB.login(function (res) {
        if (res.authResponse) {
          updateLoginStatus(updateApiMe);
          (callback || angular.noop)();
        }
      }, {
        scope: 'email,user_likes,read_friendlists'
      });
    };

    $scope.getFacebookContacts = function(page_opt) {
      if ($scope.loginStatus.status == 'connected') {
        // TODO: en prod debería funcionar esto y no mandar yo la peticion, 
        // pero en ese caso, como se a quien se envió?
        // $FB.ui({
        //     method: 'fbml.dialog',
        //     // display: 'dialog',
        //     // fbml: '<fb:header icon="false" decoration="add_border">Hello World!</fb:header><fb:profile-pic uid="5526183"></fb:profile-pic>',
        //     // link: 'http://localhost'
        // }, function(res) {
        // });

        $FB.api(page_opt || '/me/friends', { fields: 'name,id' }, function (contacts) {
          $scope.nextFbPage = contacts.paging.next;
          $scope.prevFbPage = contacts.paging.previous;
          $scope.facebookContacts = contacts.data;
          // $scope.facebookContacts.list = contacts.data;
        });
      } else {
        login($scope.getFacebookContacts);
      }
    };

    $scope.goToPage = function(page) {
      $scope.getFacebookContacts(page);
    };


    $scope.sendFbInvitation = function(friend) {
      var travellerNames = _.pluck(_.pluck($scope.travellers, 'user'), 'name');
      var message = 'Invitación para participar en la organización del viaje "' + $scope.trip.name
        + '" junto con ' + travellerNames.join(', ');
      FB.ui({method: 'apprequests',
        title: 'Organiza el viaje "' + $scope.trip.name +'" con nosotros',
        message: message,
        to: [friend.id],
      }, function(res) {
        _C(res)
      });
    };

    updateLoginStatus(updateApiMe);

  }]);