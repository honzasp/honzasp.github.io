// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  require.config({
    baseUrl: "lib",
    paths: {
      jquery: "../vendor/jquery"
    }
  });

  require(["jquery", "menu"], function($, Menu) {
    $.noConflict(true);
    return Menu.init($("#krt"));
  });

}).call(this);
