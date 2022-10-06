app.controller('googleContactsController', [
  '$scope',
  'currentUser',
  function($scope, currentUser) {
    $scope.itemsPerPage = 8;
    $scope.currentPage = 1;
    $scope.filter = {text: ''};
    $scope.googleContacts = [];

    var apiKey = 'AIzaSyDMui5Bipdm0edcP0cq5Sglm5AhnKpVQ3Q',
        clientId = '802303947908-4glfdiblmqipfcecjchbvb4tkn2p8q5r.apps.googleusercontent.com',
        scopes = 'https://www.googleapis.com/auth/plus.me';

    window.googleOnLoadCallback = function() {
      gapi.client.setApiKey(apiKey);
      gapi.auth.authorize({
        client_id: clientId,
        scope: scopes,
        immediate: false
      }, function(authResult) {
         if (authResult && !authResult.error) {
          var contactsFeedUri = '/m8/feeds/contacts/default/full';
          // gapi.client.load('plus', 'v1', function(res) {
          //   gapi.client.plus.people.list({'userId':'me', collection: 'visible'}).execute(function(res) {
          //     _C(res)
          //   })
          // })
          gapi.client.request({
            'path': contactsFeedUri,
            'params': {
              'alt': 'json',
              'max-results': 600
            }
          }).execute(function(response) {
            $scope.googleContacts = response.feed.entry;
          });
         }
      });
    };

    $scope.sendGoogleInvitation = function(contact) {
      $scope.sendInvitations([{
        email: contact.gd$email[0].address,
        trip_id: $scope.trip.id,
        name: contact.title.$t
      }]);
    };

    $scope.getNameFromMail = function(mail) {
      return mail.replace(/@.*/, '');
    };

    $scope.userFilter = function(contact) {
      if (contact.gd$email) {
        var reg = new RegExp($scope.filter.text, 'i');
        return contact.gd$email[0].address.match(reg) != null || contact.title.$t.match(reg) != null;
      }
    };

  }]);
