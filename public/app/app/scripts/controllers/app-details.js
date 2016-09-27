'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "appDataService", 'newsfeedService', 'sdkLiveScanService', 'slacktivity',
  function($scope, $http, $routeParams, $window, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, appDataService, newsfeedService, sdkLiveScanService, slacktivity) {

    $scope.appPlatform = $routeParams.platform;

    $scope.initialPageLoadComplete = false; // shows page load spinner
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo
    $scope.currentContactsPage = 1;
    $scope.contactsPerPage = 10;

    var userInfo = {}; // User info set
    authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

    // Facebook ads slideshow
    $scope.myInterval = 0;
    $scope.noWrapSlides = false;
    $scope.active = 0;

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
        $scope.canViewSdks = data.can_view_sdks;
        $scope.canViewAdSpend = data.can_view_ad_spend;
        $scope.canViewIosLiveScan = data.can_view_ios_live_scan;
        $scope.canViewStorewideSdks = data.can_view_storewide_sdks;
        $scope.canViewAdAttribution = data.can_view_ad_attribution;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

    $scope.load = function() {

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
        params: {id: $routeParams.id}
      }).success(function(data) {
        $scope.appData = data;
        if ($scope.appData.publisher && $scope.appData.publisher.websites && $scope.appData.supportDesk) {
          $scope.appData.publisher.websites.push($scope.appData.supportDesk)
        }
        $scope.isFollowing = data.following
        $scope.initialPageLoadComplete = true; // hides page load spinner
        if (data.facebookAds) {
          for (var i = 0; i < data.facebookAds.length; i++) {
            var ad = data.facebookAds[i]
            ad.id = i
          }
        }

        // Updates displayStatus for use in android-live-scan ctrl
        appDataService.displayStatus = {appId: $routeParams.id, status: data.displayStatus};
        $scope.$broadcast('APP_DATA_FOR_APP_DATA_SERVICE_SET');

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "App Page Viewed", {
            "appId": $routeParams.id,
            "appName": $scope.appData.name,
            "companyName": $scope.appData.publisher.name,
            "appPlatform": $routeParams.platform
          }
        );
        /* -------- Mixpanel Analytics End -------- */

        if ($routeParams.from == 'ewok') {
          var slacktivityData = {
            "title": "A wild Ewok appeared",
            "color": "#FFD94D",
            'appName': $scope.appData.name,
            "appPlatform": $routeParams.platform,
            'appId': $routeParams.id
          };
          slacktivity.notifySlack(slacktivityData);
        }

        /* Sets html title attribute */
        pageTitleService.setTitle($scope.appData.name);
      });
    };

    $scope.load();

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      var linkedinLink = "";

      if (linkedinLinkType == 'company') {
        linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.appData.publisher.name);
      } else {
        linkedinLink = "https://www.linkedin.com/vsearch/f?type=all&keywords=" + encodeURI($scope.appData.publisher.name) + "+" + linkedinLinkType;
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": $scope.appData.publisher.name,
          "companyPosition": linkedinLinkType
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink);
    };

    $scope.linkTo = function(path) {
      $window.location.href = path;
    };

    $scope.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
        case "followed":
          return loggitService.logSuccess("You will now see updates for this app on your Timeline");
        case "unfollowed":
          return loggitService.logSuccess("You will stop seeing updates for this app on your Timeline");
      }
    };

    $scope.addSelectedTo = function(list) {
      var selectedApp = [{
        id: $routeParams.id,
        type: $routeParams.platform
      }];
      listApiService.addSelectedTo(list, selectedApp, $scope.appPlatform).success(function() {
        $scope.notify('add-selected-success');
        $rootScope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error'); 
      });
      $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.followApp = function(id) {
      var appType = $routeParams.platform == 'ios' ? 'IosApp' : 'AndroidApp'
      newsfeedService.follow(id, appType, $scope.appData.name).success(function(data) {
        $scope.isFollowing = data.following
        if (data.following) {
          $scope.notify('followed');
        } else {
          $scope.notify('unfollowed');
        }
      });
    }

    $scope.exportContactsToCsv = function(websites, filter) {
      apiService.exportContactsToCsv(websites, filter, $scope.appData.publisher.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');

          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    /* Company Contacts Logic */
    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;
    
    $scope.getContactEmail = function(clearbitId) {
      apiService.getContactEmail(clearbitId)
        .success(function(data) {
          for(var i = 0; i < $scope.companyContacts.length; i++) {
            if ($scope.companyContacts[i].clearbitId == clearbitId) {
              $scope.companyContacts[i].email = data.email
            }
          }
        })
    }

    $scope.getCompanyContacts = function(websites, filter, page) {
      if (!page) {
        page = 1
      }
      $scope.contactsLoading = true;
      apiService.getCompanyContacts(websites, filter, page, $scope.contactsPerPage)
        .success(function(data) {
          $scope.companyContacts = data.contacts;
          $scope.contactsCount = data.contactsCount;
          $scope.contactsLoading = false;
          $scope.contactsLoaded = true;
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Company Contacts Requested", {
              'websites': websites,
              'companyName': $scope.appData.publisher.name,
              'requestResults': data.contacts,
              'requestResultsCount': data.contacts.length,
              'titleFilter': filter || ''
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        }).error(function(err) {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Company Contacts Requested", {
              'websites': websites,
              'companyName': $scope.appData.publisher.name,
              'requestError': err,
              'titleFilter': filter || ''
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          $scope.contactsLoading = false;
          $scope.contactsLoaded = false;
        });
    };
  }
]);
