'use strict';

angular.module("appApp")
  .factory("sdkLiveScanService", ['$http', 'authService', function($http, authService) {
    return {
      checkForAndroidSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/android_sdks_exist',
          params: {appId: appId}
        })
      },
      getAndroidSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/scan_android_sdks',
          params: {appId: appId}
        })
      },
      checkForIosSdks: function(appId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/ios_sdks_exist',
          params: {appId: appId}
        })
      },
      startIosSdkScan: function(appId) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/ios_start_scan',
          data: {appId: appId}
        })
      },
      getIosScanStatus: function(statusJobId) {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/ios_scan_status',
          params: {jobId: statusJobId}
        })
      },
      androidHiddenLiveScanAnalytics: function(platform, appId, displayStatus) {

        console.log('Pre H LS', 'Platform:', platform, 'App ID:', appId, 'Display Status:', displayStatus);

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {
          appData = data;

          if(platform == 'android') {
            /* -------- Mixpanel Analytics Start -------- */
            if(displayStatus != 'normal') {

              console.log('Hidden Live Scan', 'Platform:', platform, 'App ID:', appId, 'Display Status:', displayStatus);

              mixpanel.track(
                "Hidden SDK Live Scan Viewed", {
                  "userEmail": userInfo.email,
                  'appName': appData.name,
                  'companyName': appData.company.name,
                  'appId': appData.id,
                  'displayStatus': displayStatus
                }
              );
            }
            /* -------- Mixpanel Analytics End -------- */
          }

        });

      },
      androidLiveScanSuccessRequestAnalytics: function(platform, appId, sdkData) {

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          console.log('Live Scan Success', 'Platform:', platform, 'App ID:', appId, 'SDK Data:', sdkData);

          appData = data;

          var mixpanelEventTitle = "";
          var liveScanSlacktivityColor = "";

          if(sdkData.errorCode == 0) {
            mixpanelEventTitle = "SDK Live Scan Success";
            liveScanSlacktivityColor = "#45825A";
          } else if(sdkData.errorCode == 2 || sdkData.errorCode > 5) {
            mixpanelEventTitle = "SDK Live Scan Status Error";
            liveScanSlacktivityColor = "#A45200";
          } else {
            mixpanelEventTitle = "SDK Live Scan Failed";
            liveScanSlacktivityColor = "#E82020";
          }
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            mixpanelEventTitle, {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkCompanies': sdkData.sdkCompanies,
              'sdkOpenSource': sdkData.sdkOpenSource,
              'lastUpdated': sdkData.lastUpdated,
              'errorCode': sdkData.errorCode,
              'errorMessage': sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var sdkCompanies = Object.keys(sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys(sdkData.sdkOpenSource).toString();
          var slacktivityData = {
            "title": mixpanelEventTitle,
            "fallback": mixpanelEventTitle,
            "color": liveScanSlacktivityColor,
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'lastUpdated': sdkData.lastUpdated,
            'errorCode': sdkData.errorCode,
            'errorMessage': sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      androidLiveScanFailRequestAnalytics: function(platform, appId, errorStatus) {

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          console.log('Live Scan Fail', 'Platform:', platform, 'App ID:', appId, 'Error Status:', errorStatus);

          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Failed", {
              'companyName': appData.company.name,
              'appName': appData.name,
              'appId': appData.id,
              'errorStatus': errorStatus
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "SDK Live Scan Failed",
            "fallback": "SDK Live Scan Failed",
            "color": "#E82020",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'errorStatus': errorStatus
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      iosLiveScanSuccessRequestAnalytics: function(platform, appId, sdkData) {

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          console.log('IOS LIVE SCAN SUCCESS ANALYTICS LOG');

          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Success", {
              'platform': platform,
              'appName': appData.name,
              'companyName': appData.company.name,
              'appId': appData.id,
              'sdkCompanies': sdkData.sdkCompanies,
              'sdkOpenSource': sdkData.sdkOpenSource,
              'lastUpdated': sdkData.lastUpdated,
              'errorCode': sdkData.errorCode,
              'errorMessage': sdkData.errorMessage
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var sdkCompanies = Object.keys(sdkData.sdkCompanies).toString();
          var sdkOpenSource = Object.keys(sdkData.sdkOpenSource).toString();
          var slacktivityData = {
            "title": "SDK Live Scan Success",
            "fallback": "SDK Live Scan Success",
            "color": "#45825A",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'sdkCompanies': sdkCompanies,
            'sdkOpenSource': sdkOpenSource,
            'lastUpdated': sdkData.lastUpdated,
            'errorCode': sdkData.errorCode,
            'errorMessage': sdkData.errorMessage
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */

        });

      },
      iosLiveScanFailRequestAnalytics: function(platform, appId, statusCode) {

        var error = "";

        if(statusCode == 10) {
          error = "Error (status 10)"
        } else if(statusCode == -1) {
          error = "Timeout"
        }

        var userInfo = {}; // User info set
        authService.userInfo().success(function(data) { userInfo['email'] = data.email; });

        var appData = {}; // Load app data
        $http({
          method: 'GET',
          url: API_URI_BASE + 'api/get_' + platform + '_app',
          params: {id: appId}
        }).success(function(data) {

          console.log('IOS LIVE SCAN SUCCESS ANALYTICS LOG');

          appData = data;

          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "SDK Live Scan Failed", {
              'companyName': appData.company.name,
              'appName': appData.name,
              'appId': appData.id,
              'error': error
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          /* -------- Slacktivity Alerts -------- */
          var slacktivityData = {
            "title": "SDK Live Scan Failed",
            "fallback": "SDK Live Scan Failed",
            "color": "#E82020",
            "userEmail": userInfo.email,
            'appName': appData.name,
            'companyName': appData.company.name,
            'appId': appData.id,
            'error': error
          };
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
          /* -------- Slacktivity Alerts End -------- */
        });

      }
    };
  }]);
