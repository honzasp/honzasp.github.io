// Generated by CoffeeScript 1.6.3
(function() {
  define(["map"], function(Map) {
    var Window;
    Window = {};
    Window.BORDER_COLOR = "#aaa";
    Window.STAT_FONT = "12px monospace";
    Window.STAT_COLOR = "#0f0";
    Window.draw = function(game, center, tank, dim) {
      var ctx, drawObjects, drawStats, drawTile, drawTiles, lastSquare, mapToWin, winToMap;
      ctx = game.dom.ctx;
      mapToWin = function(m) {
        return {
          x: dim.scale * (m.x - center.x) + dim.w * 0.5,
          y: dim.scale * (m.y - center.y) + dim.h * 0.5
        };
      };
      winToMap = function(w) {
        return {
          x: center.x + (w.x - dim.w * 0.5) / dim.scale,
          y: center.y + (w.y - dim.h * 0.5) / dim.scale
        };
      };
      drawObjects = function() {
        return (function() {
          var bullet, particle, tank1, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
          ctx.save();
          _ref = game.tanks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tank1 = _ref[_i];
            tank1.draw(ctx);
          }
          _ref1 = game.bullets;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            bullet = _ref1[_j];
            if (!bullet.isDead) {
              bullet.draw(ctx);
            }
          }
          _ref2 = game.particles;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            particle = _ref2[_k];
            if (!particle.isDead) {
              particle.draw(ctx);
            }
          }
          return ctx.restore();
        })();
      };
      drawTiles = function() {
        var east, north, south, west, x, xMax, xMin, y, yMax, yMin, _ref, _ref1;
        _ref = winToMap({
          x: 0,
          y: 0
        }), west = _ref.x, north = _ref.y;
        _ref1 = winToMap({
          x: dim.w,
          y: dim.h
        }), east = _ref1.x, south = _ref1.y;
        xMin = Math.floor(west);
        xMax = Math.ceil(east);
        yMin = Math.floor(north);
        yMax = Math.ceil(south);
        x = xMin;
        while (x <= xMax) {
          y = yMin;
          while (y <= yMax) {
            drawTile(x, y);
            y += 1;
          }
          x += 1;
        }
        return void 0;
      };
      lastSquare = void 0;
      drawTile = function(x, y) {
        var square;
        square = Map.contains(game.map, x, y) ? Map.get(game.map, x, y) : Map.VOID;
        if (square !== lastSquare) {
          ctx.fillStyle = Map.squares[square].color;
          lastSquare = square;
        }
        return ctx.fillRect(x, y, 1, 1);
      };
      if (tank != null) {
        drawStats = function() {
          var info, progress, stat, weapon;
          info = game.playerInfos[tank.index];
          weapon = tank.weapons[tank.activeWeapon];
          progress = Array(Math.floor(weapon.temperature * 10) + 1).join(".");
          stat = ("E " + (Math.floor(tank.energy)) + " ") + ("L " + info.lives + " ") + ("H " + info.hits + " | ") + ("" + weapon.spec.name + " ") + ("" + progress);
          ctx.font = Window.STAT_FONT;
          ctx.textAlign = "left";
          ctx.fillStyle = Window.STAT_COLOR;
          return ctx.fillText(stat, 5, dim.h - 5);
        };
      } else {
        drawStats = function() {};
      }
      ctx.save();
      ctx.translate(dim.x, dim.y);
      ctx.strokeStyle = Window.BORDER_COLOR;
      ctx.strokeRect(0, 0, dim.w, dim.h);
      ctx.beginPath();
      ctx.rect(0, 0, dim.w, dim.h);
      ctx.clip();
      ctx.save();
      ctx.translate(dim.w * 0.5, dim.h * 0.5);
      ctx.scale(dim.scale, dim.scale);
      ctx.translate(-center.x, -center.y);
      drawTiles();
      drawObjects();
      ctx.restore();
      drawStats();
      return ctx.restore();
    };
    return Window;
  });

}).call(this);
