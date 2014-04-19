// Generated by CoffeeScript 1.6.3
(function() {
  define(["jquery"], function($) {
    var Loading;
    Loading = {};
    Loading.SPINNER_FPS = 3;
    Loading.SPINNER_SEQUENCE = "|/-\\";
    Loading.BITS_FPS = 10;
    Loading.BITS_LENGTH = 80;
    Loading.BITS_SYMS = "0123456789qwertyuiopasdfghjklzxcvbnm,./;'[]<>?:\"{}`~!@#$%^&*()-=\\_+|";
    Loading.init = function($root) {
      var $main, loading;
      $main = $("<div class='loading'>\n  <p>Your browser is busy preparing the game for you. It has to download\n  some files and generate the map. The algorithm requires a little noise,\n  which takes some time to compute.</p>\n  <div class='spinner'></div>\n  <div class='bits'></div>\n</div>");
      $main.appendTo($root);
      loading = {
        $main: $main,
        $root: $root,
        spinnerTimer: void 0,
        spinnerPos: 0,
        bitsTimer: void 0
      };
      loading.spinnerTimer = setInterval((function() {
        return Loading.spinnerTick(loading);
      }), 1000 / Loading.SPINNER_FPS);
      loading.bitsTimer = setInterval((function() {
        return Loading.bitsTick(loading);
      }), 1000 / Loading.BITS_FPS);
      Loading.spinnerTick(loading);
      Loading.bitsTick(loading);
      return loading;
    };
    Loading.deinit = function(loading) {
      loading.$main.remove();
      return clearInterval(loading.timer);
    };
    Loading.spinnerTick = function(loading) {
      loading.spinnerPos = (loading.spinnerPos + 1) % Loading.SPINNER_SEQUENCE.length;
      return loading.$main.find(".spinner").text(Loading.SPINNER_SEQUENCE.charAt(loading.spinnerPos));
    };
    Loading.bitsTick = function(loading) {
      var sym;
      sym = Loading.BITS_SYMS[Math.floor(Math.random() * Loading.BITS_SYMS.length)];
      return loading.$main.find(".bits").append($("<span>").text(sym));
    };
    return Loading;
  });

}).call(this);
