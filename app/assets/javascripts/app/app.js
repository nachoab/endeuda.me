'use strict';

var app = angular.module('app', [
  'ui.router',
  'ezfb',
  'ng-rails-csrf',
  'ngSanitize',
  'ngTouch',
  'rails',
  'ngAnimate',
  'ngResource',
  'ui.bootstrap',
  'ui.highlight',
  'ngProgressLite',
  'ui.keypress'
]);

app.config(['$FBProvider','ngProgressLiteProvider',
  function ($FBProvider, ngProgressLiteProvider) {
    //ngProgressLiteProvider.settings.speed = 1000; // default: 300

    $FBProvider.setLocale('es_ES');
    var myInitFunction = function ($window, $rootScope, $fbInitParams) {
      $window.FB.init({
        appId: '215473278632976'
      });
      $rootScope.$broadcast('$onFBInit');
    };
    $FBProvider.setInitFunction(myInitFunction);
  }]);