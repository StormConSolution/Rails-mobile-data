'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", function($scope, $http, $routeParams, $window) {

  $scope.load = function() {

    return $http({
      method: 'POST',
      url: API_URI_BASE + 'api/get_ios_app',
      params: {id: $routeParams.id}
    }).success(function(data) {
      $scope.appData = data;
    });
  };

  /* LinkedIn Link Button Logic */
  $scope.onLinkedinButtonClick = function(linkedinLinkType) {
    var linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.appData.company.name) + "+" + linkedinLinkType;

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "LinkedIn Link Clicked", {
        "companyName": $scope.appData.company.name,
        "companyPosition": linkedinLinkType
      }
    );
    /* -------- Mixpanel Analytics End -------- */

    $window.open(linkedinLink, '_blank');
  };

  $scope.load();

  /* -------- Mixpanel Analytics Start -------- */
  mixpanel.track(
    "App Page Viewed", {
      "appid": $routeParams.id
    }
  );
  /* -------- Mixpanel Analytics End -------- */
}
]);
