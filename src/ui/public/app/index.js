var $ = require('jquery');
var angular = require('angular');
var _ = require('lodash');
require('simple-angular-pagination');

var ui = require('leadconduit-integration-ui');

ui.init(init);

function init(config) {
  config = config || {};
  // Our app
  var app = angular.module('app', ['Pagination'])
    // $http config
    .controller('Page1Ctrl', ['$rootScope', '$scope', '$http', function($rootScope, $scope, $http) {
      var state = $rootScope.state = $rootScope.state || {};

      $rootScope.config = config;
      $rootScope.cancel = ui.cancel;

      if (config.integration) {
        state.action = _.last(config.integration.split('.'));
      }

      if (state.action == 'is_unique') {
        setTimeout(function() { $rootScope.changePage(3); }, 0);
      } else {
        $rootScope.allowPrevious = true;
        $http.get('lists').then(function(response) {
          $rootScope.lists = response.data;
        });
      }

      $rootScope.startOver = function() {
        state.action = '';
        $scope.changePage(1);
      };

      $scope.jump = function() {
        if(state.action == 'is_unique') {
          $scope.changePage(3);
        } else {
          $scope.changePage(2);
        }
      };

    }])
    .controller('Page2Ctrl', ['$rootScope', '$scope', '$http', function($rootScope, $scope, $http) {
      var state = $rootScope.state = $rootScope.state || {};

      $rootScope.fieldListText = {
        query_item: 'query',
        add_item: 'add to',
        delete_item: 'delete from'
      };

      // Finalization and communicating to the user what's next
      $scope.finish = function(){
        var steps = [{
          type: 'recipient',
          entity: {
            name: config.entity.name,
            id: config.entity.id
          },
          integration: {
            module_id: 'leadconduit-suppressionlist.outbound.' + state.action,
            mappings: [
              { property: 'values', value: '{{lead.' + state.value + '}}' },
              { property: 'list_name', value: state.list_name }
            ]
          }
        }];
        if (state.action == 'query_item') {
          steps.push({
            type: 'filter',
            reason: 'Duplicate lead',
            outcome: 'failure',
            rule_set: {
              op: 'and',
              rules: [{
                op: 'is equal to',
                lhv: 'suppressionlist.query_item.outcome',
                rhv: 'failure'
              }]
            }
          });
        }

        ui.close({
          flow: {
            steps: steps
          }
        });
      };

    }])
    .controller('Page3Ctrl', ['$rootScope', '$scope', '$http', function($rootScope, $scope, $http){
      var state = $rootScope.state = $rootScope.state || {};

      // the creds should always be there since they're from AP
      if (config.credential) {
        $http.post('credential', config.credential);
      } else {
        ui.cancel();
      }

    }])
    .controller('Page4Ctrl', ['$scope', '$rootScope', '$http', function($scope, $rootScope, $http) {

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
      $scope.finish = function(){
        $http.post('lists/ensure', {
          name: 'Duplicate Checking',
          ttl: state.ttl == 'custom' ? ((state.ttlSeconds || 0) * (state.ttlUnit || 1)) : state.ttl
        }).then(function(response) {
          ui.close({
            flow: {
              steps: [{
                type: 'recipient',
                entity: {
                  name: config.entity.name,
                  id: config.entity.id
                },
                integration: {
                  module_id: 'leadconduit-suppressionlist.outbound.is_unique',
                  mappings: [
                    { property: 'value', value: '{{lead.' + state.value + '}}' },
                    { property: 'list_name', value: response.data.url_name }
                  ]
                }
              }, {
                type: 'filter',
                reason: 'Duplicate lead',
                outcome: 'failure',
                rule_set: {
                  op: 'and',
                  rules: [{
                    op: 'is equal to',
                    lhv: 'suppressionlist.is_unique.outcome',
                    rhv: 'failure'
                  }]
                }
              }]
            }
          });
        });
      };

    }]);

  angular.bootstrap(document, ['app']);
}
