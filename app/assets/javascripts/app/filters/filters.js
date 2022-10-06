app
  .filter('dateHour', function() {
    return function(date) {
      if (date) {
        var momentDate = moment(date);
        return momentDate.format('D.M.YYYY');
      }
    };
  })
  .filter('dateTime', function() {
    return function(date) {
      if (date) {
        var momentDate = moment(date);
        return momentDate.format('H:mm');
      }
    };
  })
  .filter('unixOffset', function() {
    return function(date) {
      if (date) {
        var momentDate = moment(date);
        return momentDate.valueOf()
      }
    };
  })
  .filter('paged', function() {
    return function(input, from, to) {
      var res = [], i = 0;

      _.each(input, function(value) {
        if (i >= from && i < to) {
          res.push(value);
        }
        i++;
      });

      return res;
    };
  })
  /**
   * Filters only users in a given group
   * 
   * @param  {array}  users Array of User.
   * @param  {Group}  group Group.
   * @return {array}        Array of User.
   */
  .filter('inGroup', function() {
    return function(users, group) {
      if (group) {
        return _.filter(users, function(user) {
          return _.findWhere(group.users, { userId: user.userId }) != null;
        });
      } else {
        return users;
      }
    };
  })
  /**
   * Returns movements in the same month as param
   * 
   * @param  {array}  movements Array of Movement.
   * @param  {string} date      Date as string.
   * @return {array}            Array of Movement.
   */
  .filter('sameMonth', function() {
    return function(movements, date) {
      var month = moment(date).format('M');
      
      return _.filter(movements, function(movement) {
        return moment(movement.createdAt).format('M') == month;
      });
    };
  })
  .filter('validEmail', function() {
    return function(input) {
      return input.match(/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/) != null;
    };
  });
