angular.module('angularSinatra', ['ngRoute']);

angular
.module('angularSinatra')
.controller('SplashController', function($scope) {
});

angular
.module('angularSinatra')
.controller('AuthLoginController', function($scope, authService) {
  $scope.authenticate = function() {
    authService.checkCredentials($scope.username, $scope.password);
  }
});

angular
.module('angularSinatra')
.controller('AuthLogoutController', function($scope, authService) {
});

angular
.module('angularSinatra')
.controller('HomeController', function($scope, authService) {
  $scope.username = authService.username();
});

angular
.module('angularSinatra')
.config(['$routeProvider', '$locationProvider',
  function ($routeProvider, $locationProvider) {
    /* $locationProvider.html5Mode(true); */

    $routeProvider.when('/',
      {
        templateUrl: 'splash/index.html',
        controller: 'SplashController',
        access_required: null
      });
    $routeProvider.when('/auth/login',
      {
        templateUrl: 'auth/login.html',
        controller: 'AuthLoginController',
        access_required: null
      });
    $routeProvider.when('/auth/logout',
      {
        templateUrl: 'auth/logout.html',
        controller: 'AuthLogoutController',
        access_required: 1
      });
    $routeProvider.when('/home',
      {
        templateUrl: 'home/index.html',
        controller: 'HomeController',
        access_required: 1
      });
  }]);

angular
.module('angularSinatra')
.factory('apiService', function($http) {
  var API_LOCATION = 'http://asae.localhost/api'; /* without trailing slash */

  return {
    token: function() {
      return localStorage.getItem('api-token');
    },
    get: function(location, config) {
      return $http.get(API_LOCATION + location + '?token='+localStorage.getItem('api-token'), config);
    },
    post: function(location, data, config) {
      var data_copy = {};
      for( var key in data ) {
        data_copy[key] = data[key];
      }
      data_copy.token = localStorage.getItem('api-token');
      return $http.post(API_LOCATION + location, data_copy, config);
    }
  };
});

angular
.module('angularSinatra')
.factory('authService', function($window, $location, apiService) {
  return {
    routeIsAccessible: function(access_required) {
      if( access_required === undefined || access_required == null || access_required == 0 ) {
        return true;
      } else {
        return(
          localStorage.getItem('access') !== undefined &&
          localStorage.getItem('access') >= access_required
        );
      }
    },
    checkCredentials: function(username, password) {
      apiService.post( '/tokens', { username: username, password: password } )
      .success( function(data, status, headers, config) {
        localStorage.setItem('api-token', data.token);
        apiService.get('/user')
        .success( function(data, status, headers, config) {
          localStorage.setItem('username', data.username);
          localStorage.setItem('access', data.access);
        });
        /* localStorage.setItem('username', username); */
        /* localStorage.setItem('access', data.access); */
        $location.path('/home').replace();
      })
      .error( function(data, status) {
        alert('error: ' + status);
      });
    },
    username: function() {
      return localStorage.getItem('username');
    }
  };
});

angular.module('angularSinatra')
.run(['$rootScope', '$location', 'authService', function ($rootScope, $location, authService) {

    $rootScope.$on("$routeChangeSuccess", function (event, current) {
      if( authService.routeIsAccessible(current.$$route.access_required) ) {
        $location.path(current.$$route.originalPath);
      } else {
        $location.path('/auth/login');
      }
    });

}]);
