angular.module('angularSinatra', ['ngRoute']);

angular
.module('angularSinatra')
.controller('SplashController', function($scope, apiService, authService) {
  $scope.loggedIn = authService.loggedIn();

  apiService.get('/data-only-users-can-see')
  .success( function(data, status) {
    $scope.userData = data.data;
  } );

  apiService.get('/data-only-admins-can-see')
  .success( function(data, status) {
    $scope.adminData = data.data;
  } );
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
.controller('AuthLogoutController', function($scope, $location, authService) {
  authService.logOut();
  $location.path('/').replace();
});

angular
.module('angularSinatra')
.controller('HomeController', function($scope, authService, apiService) {
  $scope.username = authService.username();
  apiService.get('/data-only-users-can-see')
  .success( function(data, status) {
    $scope.data = data.data;
  } );
});

angular
.module('angularSinatra')
.controller('AdminController', function($scope, authService, apiService) {
  $scope.username = authService.username();
  apiService.get('/data-only-admins-can-see')
  .success( function(data, status) {
    $scope.data = data.data;
  } );
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
        accessRequired: null
      });
    $routeProvider.when('/auth/login',
      {
        templateUrl: 'auth/login.html',
        controller: 'AuthLoginController',
        accessRequired: null
      });
    $routeProvider.when('/auth/logout',
      {
        template: '',
        controller: 'AuthLogoutController',
        accessRequired: 1,
      });
    $routeProvider.when('/home',
      {
        templateUrl: 'home/index.html',
        controller: 'HomeController',
        accessRequired: 1
      });
    $routeProvider.when('/admin',
      {
        templateUrl: 'admin/index.html',
        controller: 'AdminController',
        accessRequired: 9
      });
  }]);

angular
.module('angularSinatra')
.factory('apiService', function($http) {
  /* without trailing slash */
  /* var API_LOCATION = 'http://yourdomain.com/api'; */
  var API_LOCATION = '/api';

  return {
    token: function() {
      return localStorage.getItem('api-token');
    },
    get: function(location, config) {
      return $http.get(API_LOCATION + location + '?token='+localStorage.getItem('api-token'), config);
    },
    delete: function(location, config) {
      return $http.delete(API_LOCATION + location + '?token='+localStorage.getItem('api-token'), config);
    },
    post: function(location, data, config) {
      var dataCopy = {};
      for( var key in data ) {
        dataCopy[key] = data[key];
      }
      dataCopy.token = localStorage.getItem('api-token');
      return $http.post(API_LOCATION + location, dataCopy, config);
    }
  };
});

angular
.module('angularSinatra')
.factory('authService', function($window, $location, apiService) {
  return {
    routeIsAccessible: function(accessRequired) {
      if( accessRequired === undefined || accessRequired == null || accessRequired == 0 ) {
        return true;
      } else {
        return(
          localStorage.getItem('access') !== undefined &&
          localStorage.getItem('access') >= accessRequired
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
          $location.path(localStorage.getItem('post-login-path') || '/home').replace();
        });
      })
      .error( function(data, status) {
        alert('error: ' + status);
      });
    },
    username: function() {
      return localStorage.getItem('username');
    },
    loggedIn: function() {
      return !! this.username();
    },
    logOut: function() {
      apiService.delete('/tokens');
      localStorage.removeItem('username');
      localStorage.removeItem('access');
    }
  };
});

angular.module('angularSinatra')
.run(['$rootScope', '$location', 'authService', function ($rootScope, $location, authService) {

  $rootScope.$on("$routeChangeSuccess", function (event, current, last) {
    if( authService.routeIsAccessible(current.$$route.accessRequired) ) {
      $location.path(current.$$route.originalPath).replace();
    } else {
      if( authService.loggedIn() ) {
        alert('Not authorized.');
        $location.path(last.$$route.originalPath).replace();
      } else {
        localStorage.setItem('post-login-path', current.$$route.originalPath);
        $location.path('/auth/login').replace();
      }
    }
  });

}]);
