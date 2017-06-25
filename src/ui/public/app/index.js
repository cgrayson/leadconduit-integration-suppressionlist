var $ = require('jquery');
var angular = require('angular');
var _ = require('lodash');
require('simple-angular-pagination');

var ui = require('leadconduit-integration-ui');

ui.init(init);

function init(config) {
  console.log('really initial');
  config = config || {};
  // Our app
  var app = angular.module('app', ['Pagination'])
    // $http config
    .config(['$httpProvider', '$locationProvider', function($httpProvider, $locationProvider) {
      $locationProvider.html5Mode({
        enabled: true,
        requireBase: false
      });

      // Handle special cases when interacting with the API
      $httpProvider.interceptors.push(['$q', '$rootScope', function($q, $rootScope) {
        return {
          responseError: function(response) {
            if (response.status == 401) {
              $rootScope.requiresAuth = true;
            }
            $rootScope.error = response.error;
            return $q.reject(response);
          }
        };
      }]);
    }])
    .controller('Page1Ctrl', ['$rootScope', '$scope', '$http', function($rootScope, $scope, $http){
      var state = $rootScope.state = $rootScope.state || {};

      state.action = 'is_unique';

      // the creds should always be there since they're from AP
      if (config.credential) {
        $http.post('credential', config.credential);
      } else {
        ui.cancel();
      }

      $rootScope.config = config;
      $rootScope.cancel = ui.cancel;
    }])
    .controller('Page2Ctrl', ['$scope', '$rootScope', '$http', function($scope, $rootScope, $http) {

      var state = $rootScope.state = $rootScope.state || {};
      $scope.amounts = [
        { value: 10, text: '10 seconds' },
        { value: 10 * 60, text: '10 minutes' },
        { value: 60 * 60, text: '1 hour' },
        { value: 24 * 60 * 60, text: '1 day' },
        { value: 7 * 24 * 60 * 60, text: '1 week' },
        { value: 31 * 24 * 60 * 60, text: '1 month' },
        { value: 'custom', text: 'Custom' }
      ];

      $scope.units = [
        { value: 1, text: 'seconds' },
        { value: 60, text: 'minutes' },
        { value: 60 * 60, text: 'hours' },
        { value: 24 * 60 * 60, text: 'days' },
        { value: 7 * 24 * 60 * 60, text: 'weeks' }
      ];

      // Finalization and communicating to the user what's next
      $rootScope.finish = function(){
        $http.post('ensure_list', {
          name: 'Duplicate Checking',
          ttl: state.ttl == 'custom' ? ((state.ttlSeconds || 0) * (state.ttlUnit || 1)) : state.ttl
        }).then(function(response) {
          console.log('dup', response);
          return;
          ui.close({
            flow: {
              steps: [{
                type: 'recipient',
                entity: {
                  name: config.entity.name,
                  id: config.entity.id
                },
                integration: {
                  module_id: 'leadconduit-suppressionlist.outbound.' + state.action,
                  mappings: [
                    { property: 'values', value: '{{lead.' + state.values + '}}' },
                    { property: 'list_name' }
                  ]
                }
              }]
            }
          });
        });
      };

    }]);

  angular.bootstrap(document, ['app']);
}
