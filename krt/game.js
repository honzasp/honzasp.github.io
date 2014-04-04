// Generated by CoffeeScript 1.6.3
(function() {
  define(["jquery", "map", "window", "tank", "bullet", "collisions"], function($, Map, Window, Tank, Bullet, Collisions) {
    var Game;
    Game = {};
    Game.MAX_GARBAGE_RATIO = 0.5;
    Game.init = function($root, settings) {
      var game;
      game = {
        dom: Game.init.prepareDom($root),
        map: Game.init.createMap(settings),
        tanks: Game.init.createTanks(settings),
        bullets: [],
        size: {
          x: 800,
          y: 600
        },
        events: void 0,
        tickLen: 1.0 / settings["fps"],
        timer: void 0
      };
      Game.resizeCanvas(game);
      Game.rebindListeners(game);
      return game;
    };
    Game.init.prepareDom = function($root) {
      var $canvas, $main, ctx;
      $main = $("<div />").appendTo($root);
      $canvas = $("<canvas />").appendTo($main);
      ctx = $canvas[0].getContext("2d");
      return {
        $root: $root,
        $main: $main,
        $canvas: $canvas,
        ctx: ctx
      };
    };
    Game.init.createMap = function(settings) {
      var map, x, y, _i, _j;
      map = Map.init(settings["map width"], settings["map height"]);
      for (y = _i = 2; _i <= 20; y = ++_i) {
        for (x = _j = 3; _j <= 13; x = ++_j) {
          Map.set(map, x, y, Map.ROCK);
        }
      }
      Map.set(map, 4, 3, Map.STEEL);
      return map;
    };
    Game.init.createTanks = function(settings) {
      return [Tank.init(1.8, 2.0), Tank.init(3.0, 1.2)];
    };
    Game.rebindListeners = function(game) {
      if (game.events != null) {
        Game.unbindListeners(game);
      }
      game.events = Game.events(game);
      $(document).on("keydown", game.events.keydown);
      return $(document).on("keyup", game.events.keyup);
    };
    Game.unbindListeners = function(game) {
      if (game.events == null) {
        return;
      }
      $(document).off("keydown", game.events.keydown);
      $(document).off("keyup", game.events.keyup);
      return game.events = void 0;
    };
    Game.events = function(game) {
      return {
        keydown: function(evt) {
          switch (evt.which) {
            case 87:
              return game.tanks[0].acc = 1;
            case 83:
              return game.tanks[0].acc = -1;
            case 65:
              return game.tanks[0].rot = 1;
            case 68:
              return game.tanks[0].rot = -1;
            case 81:
              return Tank.fire(game.tanks[0], game);
          }
        },
        keyup: function(evt) {
          switch (evt.which) {
            case 87:
              if (game.tanks[0].acc > 0) {
                return game.tanks[0].acc = 0;
              }
              break;
            case 83:
              if (game.tanks[0].acc < 0) {
                return game.tanks[0].acc = 0;
              }
              break;
            case 65:
              if (game.tanks[0].rot > 0) {
                return game.tanks[0].rot = 0;
              }
              break;
            case 68:
              if (game.tanks[0].rot < 0) {
                return game.tanks[0].rot = 0;
              }
          }
        }
      };
    };
    Game.resizeCanvas = function(game) {
      game.dom.$canvas.attr("width", game.size.x);
      return game.dom.$canvas.attr("height", game.size.y);
    };
    Game.start = function(game) {
      if (game.timer != null) {
        Game.stop(game);
      }
      return game.timer = setInterval((function() {
        return Game.tick(game);
      }), game.tickLen * 1000);
    };
    Game.stop = function(game) {
      if (game.timer != null) {
        clearInterval(game.timer);
      }
      return game.timer = void 0;
    };
    Game.tick = function(game) {
      Game.update(game, game.tickLen);
      return Game.draw(game);
    };
    Game.draw = function(game) {
      return Window.draw(game, game.tanks[0].pos, {
        x: 0,
        y: 0,
        w: game.size.x,
        h: game.size.y,
        scale: 16
      });
    };
    Game.update = function(game, t) {
      Game.updateTanks(game, t);
      return Game.updateBullets(game, t);
    };
    Game.updateTanks = function(game, t) {
      var i, j, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _ref4;
      for (i = _i = 0, _ref = game.tanks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        Tank.move(game.tanks[i], t);
      }
      for (i = _j = 0, _ref1 = game.tanks.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        for (j = _k = _ref2 = i + 1, _ref3 = game.tanks.length; _ref2 <= _ref3 ? _k < _ref3 : _k > _ref3; j = _ref2 <= _ref3 ? ++_k : --_k) {
          Collisions.tankTank(game.tanks[i], game.tanks[j]);
        }
      }
      for (i = _l = 0, _ref4 = game.tanks.length; 0 <= _ref4 ? _l < _ref4 : _l > _ref4; i = 0 <= _ref4 ? ++_l : --_l) {
        Collisions.tankMap(game.tanks[i], game.map);
      }
      return void 0;
    };
    Game.updateBullets = function(game, t) {
      var bullets, dead, i, p, _i, _j, _ref, _ref1;
      bullets = game.bullets;
      dead = 0;
      for (i = _i = 0, _ref = bullets.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (!bullets[i].isDead) {
          Collisions.bullet(bullets[i], t, game.map, game.tanks);
          Bullet.move(bullets[i], t);
        } else {
          dead = dead + 1;
        }
      }
      if (dead > bullets.length * Game.MAX_GARBAGE_RATIO) {
        p = 0;
        for (i = _j = 0, _ref1 = bullets.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if (!bullets[i].isDead) {
            bullets[p] = bullets[i];
            p = p + 1;
          }
        }
        return bullets.length = p;
      }
    };
    return Game;
  });

}).call(this);
