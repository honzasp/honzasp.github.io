// Generated by CoffeeScript 1.6.3
(function() {
  define(["jquery", "game"], function($, Game) {
    var Menu;
    Menu = {};
    Menu.init = function($root) {
      var menu;
      menu = {
        dom: Menu.init.prepareDom($root),
        game: void 0
      };
      Menu.init.bindListeners(menu);
      return menu;
    };
    Menu.init.prepareDom = function($root) {
      var $main, $playBtn, $playerCountInp;
      $main = $("<div />").appendTo($root);
      $playBtn = $("<input type='button' value='Play' name='play'>").appendTo($main);
      $playerCountInp = $("<input type='text' value='2' name='player-count'>").appendTo($main);
      return {
        $root: $root,
        $main: $main,
        $playBtn: $playBtn,
        $playerCountInp: $playerCountInp
      };
    };
    Menu.init.bindListeners = function(menu) {
      return menu.dom.$playBtn.click(function() {
        return Menu.play(menu);
      });
    };
    Menu.play = function(menu) {
      var playerCount, settings;
      playerCount = Math.floor(menu.dom.$playerCountInp.val() * 1);
      if (!(playerCount >= 1 && playerCount <= 4)) {
        Menu.error("Please select one to four players");
        return;
      }
      settings = {
        fps: 30,
        mapWidth: 100,
        mapHeight: 50,
        playerCount: playerCount
      };
      if (menu.game == null) {
        menu.game = Game.init(menu.dom.$root, settings);
        return Game.start(menu.game);
      }
    };
    return Menu;
  });

}).call(this);
