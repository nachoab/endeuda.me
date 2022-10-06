app
  .directive('stopEvent', function() {
    return {
      restrict: 'A',
      link: function (scope, element, attr) {
        element.bind(attr.stopEvent, function(e) {
          e.stopPropagation();
        });
      }
    };
  })
  // Event fired after space added
  .directive('ngSpace', function() {
    return {
      restrict: 'A',
      link: function (scope, element, attrs) {
        element.bind("keydown keypress", function(event) {
          if (event.which === 32) {
            scope.$apply(function() {
              scope.$eval(attrs.ngSpace);
            });
            event.preventDefault();
          }
        });
      }
    };
  })
  .directive('selectMe', ['$timeout', function($timeout) {
    return {
      scope: { trigger: '=selectMe' },
      link: function (scope, element) {
        scope.$watch('trigger', function(value) {
          if(value === true) { 
              element[0].select();
          }
        });
      }
    };
  }])
  .directive('animatedClick', function(){
    return function (scope, elm, attrs) {
      elm.bind('click', function(e){
        e.preventDefault();
        elm.parents('li').addClass(attrs.clickAnimation);
        setTimeout(function(){
          scope.$apply(function(){
            scope.$eval(attrs.animatedClick);
          });
      }, 100);                    
      });
    };
  })
  // Auto focus an input when is rendered.
  // Use: focus="true"
  .directive('focus', ['$timeout', function ($timeout) {
    return function (scope, element, attrs) {
      $timeout(function () {
        attrs.$observe('focus', function (newValue) {
          newValue === 'true' && element[0].focus();
        });
        attrs.focus === 'true' && element[0].focus();
      }, 50); 
    }
  }])
  .directive('infiniteScroll', function() {
    return function(scope, elm, attr) {
      var raw = elm[0];

      elm.bind('scroll', function() {
        if (raw.scrollTop + raw.offsetHeight >= (raw.scrollHeight - parseInt(attr.infiniteScrollDistance))) {
          scope.$apply(attr.infiniteScroll);
        }
      });
    };
  })
  .directive('confirm', [function () {
    return {
      priority: 100,
      restrict: 'A',
      link: {
        pre: function (scope, element, attrs) {
          var msg = attrs.confirm || "Are you sure?";

          element.bind('click', function (event) {
            if (!confirm(msg)) {
              event.stopImmediatePropagation();
              event.preventDefault;
            }
          });
        }
      }
    };
  }]);