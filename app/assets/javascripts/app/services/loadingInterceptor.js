/**
  * Angular rails resource (BEST OPTION)
  * https://github.com/FineLinePrototyping/angularjs-rails-resource#interceptors
  */

app.factory('loadingRailsInterceptor', ['ngProgressLite', function (ngProgressLite) {
  var numLoadings = 0;

  return {
    'beforeRequest': function (httpConfig, resourceConstructor, context) {
      numLoadings++;
      ngProgressLite.start();
      return httpConfig;
    },
    'afterResponse': function (result, resourceConstructor, context) {
      if ((--numLoadings) === 0) {
        ngProgressLite.done();
      } else {
        ngProgressLite.inc();
      }
      return result;                    
    },
    'afterResponseError': function (rejection, resourceConstructor, context) {
      if (!(--numLoadings)) {
        ngProgressLite.done();
      } else {
        ngProgressLite.inc();

      }
      return false;
      // return $q.reject(rejection);
    }
  };
}]);
