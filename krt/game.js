// Generated by CoffeeScript 1.6.3
(function() {
  define(["exports", "jquery", "map", "window", "tank", "bullet", "particle", "collisions"], function(exports, $, Map, Window, Tank, Bullet, Particle, Collisions) {
    var Game;
    Game = exports;
    Game.MAX_GARBAGE_RATIO = 0.5;
    Game.BASE_SIZE = 8;
    Game.BASE_DOOR_SIZE = 2;
    Game.init = function($root, settings, callback) {
      var game, info, playerInfos;
      playerInfos = Game.init.createPlayers(settings);
      game = {
        dom: Game.init.prepareDom($root),
        map: Game.init.createMap(settings, playerInfos),
        tanks: (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = playerInfos.length; _i < _len; _i++) {
            info = playerInfos[_i];
            _results.push(Game.createTank(game, info));
          }
          return _results;
        })(),
        bullets: [],
        particles: [],
        size: {
          x: 800,
          y: 600
        },
        events: void 0,
        tickLen: 1.0 / settings["fps"],
        timer: void 0,
        playerInfos: playerInfos,
        callback: callback
      };
      Game.resizeCanvas(game);
      Game.rebindListeners(game);
      return game;
    };
    Game.init.prepareDom = function($root) {
      var $canvas, $main, ctx;
      $main = $("<div />").appendTo($root);
      $canvas = $("<canvas />").appendTo($main);
      $canvas.css({
        "display": "block",
        "position": "absolute",
        "top": "0px",
        "left": "0px",
        "margin": "0px",
        "padding": "0px"
      });
      ctx = $canvas[0].getContext("2d");
      return {
        $root: $root,
        $main: $main,
        $canvas: $canvas,
        ctx: ctx
      };
    };
    Game.init.createPlayers = function(settings) {
      var def, idx, x, y, _i, _len, _ref, _results;
      _ref = settings.playerDefs;
      _results = [];
      for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
        def = _ref[idx];
        x = Math.floor(Math.random() * (settings.mapWidth - Game.BASE_SIZE));
        y = Math.floor(Math.random() * (settings.mapHeight - Game.BASE_SIZE));
        _results.push({
          index: idx,
          base: {
            x: x,
            y: y
          },
          lives: settings.startLives,
          hits: 0,
          keys: def.keys
        });
      }
      return _results;
    };
    Game.init.createMap = function(settings, playerInfos) {
      var dx, i, j, map, playerInfo, s, x, y, _i, _j, _k, _l, _len, _m, _n, _o, _ref, _ref1, _ref2, _ref3;
      map = Map.init(settings.mapWidth, settings.mapHeight);
      for (y = _i = 2; _i <= 20; y = ++_i) {
        for (x = _j = 3; _j <= 13; x = ++_j) {
          Map.set(map, x, y, Map.ROCK);
        }
      }
      Map.set(map, 4, 3, Map.STEEL);
      for (_k = 0, _len = playerInfos.length; _k < _len; _k++) {
        playerInfo = playerInfos[_k];
        _ref = playerInfo.base, x = _ref.x, y = _ref.y;
        s = Game.BASE_SIZE;
        for (i = _l = 0; 0 <= s ? _l < s : _l > s; i = 0 <= s ? ++_l : --_l) {
          Map.set(map, x + i, y, Map.TITANIUM);
          Map.set(map, x + i, y + s - 1, Map.TITANIUM);
          Map.set(map, x, y + i, Map.TITANIUM);
          Map.set(map, x + s - 1, y + i, Map.TITANIUM);
        }
        for (i = _m = 1, _ref1 = s - 1; 1 <= _ref1 ? _m < _ref1 : _m > _ref1; i = 1 <= _ref1 ? ++_m : --_m) {
          for (j = _n = 1, _ref2 = s - 1; 1 <= _ref2 ? _n < _ref2 : _n > _ref2; j = 1 <= _ref2 ? ++_n : --_n) {
            Map.set(map, x + i, y + j, Map.EMPTY);
          }
        }
        for (i = _o = 0, _ref3 = Game.BASE_DOOR_SIZE; 0 <= _ref3 ? _o < _ref3 : _o > _ref3; i = 0 <= _ref3 ? ++_o : --_o) {
          dx = x + Math.floor(s / 2 - Game.BASE_DOOR_SIZE / 2) + i;
          Map.set(map, dx, y, Map.EMPTY);
          Map.set(map, dx, y + s - 1, Map.EMPTY);
        }
      }
      return map;
    };
    Game.createTank = function(game, playerInfo) {
      var idx, x, y, _ref;
      idx = playerInfo.index, (_ref = playerInfo.base, x = _ref.x, y = _ref.y);
      return new Tank(idx, x + Game.BASE_SIZE / 2, y + Game.BASE_SIZE / 2);
    };
    Game.deinit = function(game) {
      Game.stop(game);
      Game.unbindListeners(game);
      game.dom.$main.remove();
      return game.callback();
    };
    Game.tankDestroyed = function(game, index, guilty) {
      if (guilty == null) {
        guilty = void 0;
      }
      game.tanks[index] = Game.createTank(game, game.playerInfos[index]);
      if (guilty != null) {
        game.playerInfos[guilty].hits += 1;
      }
      game.playerInfos[index].lives -= 1;
      if (game.playerInfos[index].lives <= 0) {
        return Game.finish(game);
      }
    };
    Game.rebindListeners = function(game) {
      if (game.events != null) {
        Game.unbindListeners(game);
      }
      game.events = Game.events(game);
      return $(window).on(game.events);
    };
    Game.unbindListeners = function(game) {
      if (game.events == null) {
        return;
      }
      $(window).off(game.events);
      return game.events = void 0;
    };
    Game.events = function(game) {
      var backwardOff, backwardOn, fireOff, fireOn, forwardOff, forwardOn, leftOff, leftOn, rightOff, rightOn;
      forwardOn = function(idx) {
        return game.tanks[idx].acc = 1;
      };
      backwardOn = function(idx) {
        return game.tanks[idx].acc = -1;
      };
      leftOn = function(idx) {
        return game.tanks[idx].rot = 1;
      };
      rightOn = function(idx) {
        return game.tanks[idx].rot = -1;
      };
      fireOn = function(idx) {
        return game.tanks[idx].fire(game);
      };
      forwardOff = function(idx) {
        if (game.tanks[idx].acc > 0) {
          return game.tanks[idx].acc = 0;
        }
      };
      backwardOff = function(idx) {
        if (game.tanks[idx].acc < 0) {
          return game.tanks[idx].acc = 0;
        }
      };
      leftOff = function(idx) {
        if (game.tanks[idx].rot > 0) {
          return game.tanks[idx].rot = 0;
        }
      };
      rightOff = function(idx) {
        if (game.tanks[idx].rot < 0) {
          return game.tanks[idx].rot = 0;
        }
      };
      fireOff = function(idx) {};
      return {
        keydown: function(evt) {
          var idx, keys, _i, _len, _ref;
          _ref = game.playerInfos;
          for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
            keys = _ref[idx].keys;
            if (evt.which === keys.forward) {
              forwardOn(idx);
            }
            if (evt.which === keys.backward) {
              backwardOn(idx);
            }
            if (evt.which === keys.left) {
              leftOn(idx);
            }
            if (evt.which === keys.right) {
              rightOn(idx);
            }
            if (evt.which === keys.fire) {
              fireOn(idx);
            }
          }
          return void 0;
        },
        keyup: function(evt) {
          var idx, keys, _i, _len, _ref;
          _ref = game.playerInfos;
          for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
            keys = _ref[idx].keys;
            if (evt.which === keys.forward) {
              forwardOff(idx);
            }
            if (evt.which === keys.backward) {
              backwardOff(idx);
            }
            if (evt.which === keys.left) {
              leftOff(idx);
            }
            if (evt.which === keys.right) {
              rightOff(idx);
            }
            if (evt.which === keys.fire) {
              fireOff(idx);
            }
          }
          return void 0;
        },
        resize: function(evt) {
          return Game.resizeCanvas(game);
        }
      };
    };
    Game.resizeCanvas = function(game) {
      game.size.x = window.innerWidth;
      game.size.y = window.innerHeight;
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
    Game.finish = function(game) {
      return Game.deinit(game);
    };
    Game.tick = function(game) {
      Game.update(game, game.tickLen);
      return Game.draw(game);
    };
    Game.draw = function(game) {
      switch (game.playerInfos.length) {
        case 1:
          return Window.draw(game, game.tanks[0].pos, game.tanks[0], {
            x: 0,
            y: 0,
            w: game.size.x,
            h: game.size.y,
            scale: 16
          });
        case 2:
          Window.draw(game, game.tanks[0].pos, game.tanks[0], {
            x: 0,
            y: 0,
            w: game.size.x / 2,
            h: game.size.y,
            scale: 14
          });
          return Window.draw(game, game.tanks[1].pos, game.tanks[1], {
            x: game.size.x / 2,
            y: 0,
            w: game.size.x / 2,
            h: game.size.y,
            scale: 14
          });
        case 3:
          Window.draw(game, game.tanks[0].pos, game.tanks[0], {
            x: 0,
            y: 0,
            w: game.size.x / 3,
            h: game.size.y,
            scale: 13
          });
          Window.draw(game, game.tanks[1].pos, game.tanks[1], {
            x: game.size.x / 3,
            y: 0,
            w: game.size.x / 3,
            h: game.size.y,
            scale: 13
          });
          return Window.draw(game, game.tanks[2].pos, game.tanks[2], {
            x: 2 * game.size.x / 3,
            y: 0,
            w: game.size.x / 3,
            h: game.size.y,
            scale: 13
          });
        case 4:
          Window.draw(game, game.tanks[0].pos, game.tanks[0], {
            x: 0,
            y: 0,
            w: game.size.x / 2,
            h: game.size.y / 2,
            scale: 12
          });
          Window.draw(game, game.tanks[1].pos, game.tanks[1], {
            x: game.size.x / 2,
            y: 0,
            w: game.size.x / 2,
            h: game.size.y / 2,
            scale: 12
          });
          Window.draw(game, game.tanks[2].pos, game.tanks[2], {
            x: 0,
            y: game.size.y / 2,
            w: game.size.x / 2,
            h: game.size.y / 2,
            scale: 12
          });
          return Window.draw(game, game.tanks[3].pos, game.tanks[3], {
            x: game.size.x / 2,
            y: game.size.y / 2,
            w: game.size.x / 2,
            h: game.size.y / 2,
            scale: 12
          });
        default:
          throw new Error("Unknown layout for given count of players");
      }
    };
    Game.update = function(game, t) {
      Game.updateBullets(game, t);
      Game.updateParticles(game, t);
      return Game.updateTanks(game, t);
    };
    Game.updateTanks = function(game, t) {
      var i, j, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _ref4;
      for (i = _i = 0, _ref = game.tanks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        game.tanks[i].move(t);
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
      return Game.updateLiving(game, game.bullets, function(bullet) {
        Collisions.bullet(bullet, game, t);
        return bullet.move(t);
      });
    };
    Game.updateParticles = function(game, t) {
      return Game.updateLiving(game, game.particles, function(particle) {
        return particle.move(t);
      });
    };
    Game.updateLiving = function(game, objs, update) {
      var dead, i, p, _i, _j, _ref, _ref1;
      dead = 0;
      for (i = _i = 0, _ref = objs.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (!objs[i].isDead) {
          update(objs[i]);
        } else {
          dead = dead + 1;
        }
      }
      if (dead > objs.length * Game.MAX_GARBAGE_RATIO) {
        p = 0;
        for (i = _j = 0, _ref1 = objs.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if (!objs[i].isDead) {
            objs[p] = objs[i];
            p = p + 1;
          }
        }
        return objs.length = p;
      }
    };
    return Game;
  });

}).call(this);
