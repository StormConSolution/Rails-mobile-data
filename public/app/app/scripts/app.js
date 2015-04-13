'use strict';

/**
 * Main module of the application.
 */

angular
  .module('appApp', [
    'ngRoute',
    'ngSanitize',
    'app.directives',
    'app.chart.directives',
    'app.ui.form.directives'
  ])
  .run(function () {

      $(document).ready(function(){

        setTimeout(function(){
          $('.page-loading-overlay').addClass("loaded");
          $('.load_circle_wrapper').addClass("loaded");
        },1000);

      });

    })
  .config(function ($routeProvider) {
     $routeProvider
      .when('/', {
        templateUrl: '../app/views/dashboard.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/views/404.html'
      });
  });

