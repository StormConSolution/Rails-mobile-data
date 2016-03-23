'use strict';

angular.module('appApp').controller("NewsfeedCtrl", ["$scope", "$http", "pageTitleService", "listApiService", "apiService", 'sdkLiveScanService', 'newsfeedService',
  function($scope, $http, pageTitleService, listApiService, apiService, sdkLiveScanService, newsfeedService) {

    var newsfeedCtrl = this;
    $scope.initialPageLoadComplete = false;
    $scope.isCollapsed = true;
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo

    newsfeedCtrl.load = function() {

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed'
      }).success(function(data) {
        newsfeedCtrl.weeks = data.weeks;
        $scope.following = data.following
        $scope.initialPageLoadComplete = true;

        // Sets html title attribute
        pageTitleService.setTitle('MightySignal - Timeline');

      });

    };

    newsfeedCtrl.load();

    $scope.loadBatch = function(id, batch, page, perPage) {
      page = page || 1

      mixpanel.track("Expanded Timeline Item", {
        activityType: batch.activity_type,
        owner: batch.owner.name,
        platform: batch.owner.platform,
        type: batch.owner.type
      });

      $http({
        method: 'GET',
        url: API_URI_BASE + 'api/newsfeed_details',
        params: {batchId: id, pageNum: page, perPage: perPage}
      }).success(function(data) {
        batch.activities = data.activities;
        batch.currentPage = data.page
      });
    }

    $scope.newFollow = function(id, type, name, follow) {
      newsfeedService.follow(id, type, name).success(function(data) {
        follow.isFollowing = data.following
      });
    }

    mixpanel.track("Timeline Viewed");
  }
]);