// Generated by CoffeeScript 1.6.3
(function() {
  define(["map", "tank"], function(Map, Tank) {
    var Render;
    Render = {};
    Render.BORDER_COLOR = "#aaa";
    Render.STAT_FONT = "12px monospace";
    Render.STAT_SHADOW_BLUR = 3;
    Render.STAT_SHADOW_COLOR = "rgba(255, 239, 171, 0.5)";
    Render.STAT_MARGIN = 16;
    Render.HUD_MARGIN = 5;
    Render.HUD_ROW = 12;
    Render.NAME_TAG_FONT = "0.8px monospace";
    Render.NAME_TAG_MARGIN = 4;
    Render.game = function(game) {
      var h, scale, w, _ref, _ref1, _ref2, _ref3;
      switch (game.playerInfos.length) {
        case 1:
          _ref = [game.size.x, game.size.y, 17], w = _ref[0], h = _ref[1], scale = _ref[2];
          return Render.window(game, game.tanks[0], {
            x: 0,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
        case 2:
          _ref1 = [game.size.x / 2, game.size.y, 16], w = _ref1[0], h = _ref1[1], scale = _ref1[2];
          Render.window(game, game.tanks[0], {
            x: 0,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
          return Render.window(game, game.tanks[1], {
            x: w,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
        case 3:
          _ref2 = [game.size.x / 3, game.size.y, 15], w = _ref2[0], h = _ref2[1], scale = _ref2[2];
          Render.window(game, game.tanks[0], {
            x: 0,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
          Render.window(game, game.tanks[1], {
            x: w,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
          return Render.window(game, game.tanks[2], {
            x: 2 * w,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
        case 4:
          _ref3 = [game.size.x / 2, game.size.y / 2, 14], w = _ref3[0], h = _ref3[1], scale = _ref3[2];
          Render.window(game, game.tanks[0], {
            x: 0,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
          Render.window(game, game.tanks[1], {
            x: w,
            y: 0,
            w: w,
            h: h,
            scale: scale
          });
          Render.window(game, game.tanks[2], {
            x: 0,
            y: h,
            w: w,
            h: h,
            scale: scale
          });
          return Render.window(game, game.tanks[3], {
            x: w,
            y: h,
            w: w,
            h: h,
            scale: scale
          });
        default:
          throw new Error("Unknown layout for " + game.playerInfos.length + " players");
      }
    };
    Render.window = function(game, tank, win) {
      var center, ctx;
      center = {
        x: tank.pos.x,
        y: tank.pos.y,
        angle: tank.angle + Math.PI
      };
      ctx = game.dom.ctx;
      ctx.save();
      ctx.translate(win.x, win.y);
      ctx.beginPath();
      ctx.rect(0, 0, win.w, win.h);
      ctx.strokeStyle = Render.BORDER_COLOR;
      ctx.stroke();
      ctx.clip();
      if (tank.energy < Tank.VISION_ENERGY) {
        ctx.globalAlpha *= 1 - 0.8 * (Tank.VISION_ENERGY - tank.energy) / Tank.VISION_ENERGY;
      }
      ctx.save();
      ctx.translate(win.w * 0.5, win.h * 0.5);
      if (game.rotateViewport) {
        ctx.rotate(center.angle);
      }
      ctx.scale(win.scale, win.scale);
      ctx.translate(-center.x, -center.y);
      Render.map(ctx, game, win, center);
      Render.objects(ctx, game);
      if (game.useNameTags) {
        Render.nameTags(ctx, game, win, center);
      }
      ctx.restore();
      Render.stats(ctx, game, tank, win);
      return ctx.restore();
    };
    Render.objects = function(ctx, game) {
      var bonus, bullet, particle, tank, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
      ctx.save();
      _ref = game.tanks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tank = _ref[_i];
        tank.render(ctx);
      }
      _ref1 = game.bullets;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        bullet = _ref1[_j];
        if (!bullet.isDead) {
          bullet.render(ctx);
        }
      }
      _ref2 = game.particles;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        particle = _ref2[_k];
        if (!particle.isDead) {
          particle.render(ctx);
        }
      }
      _ref3 = game.bonuses;
      for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
        bonus = _ref3[_l];
        if (!bonus.isDead) {
          bonus.render(ctx);
        }
      }
      return ctx.restore();
    };
    Render.nameTags = function(ctx, game, win, center) {
      var name, tank, x, y, _i, _len, _ref, _ref1;
      _ref = game.tanks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tank = _ref[_i];
        name = game.playerInfos[tank.index].name;
        _ref1 = tank.pos, x = _ref1.x, y = _ref1.y;
        ctx.save();
        ctx.translate(x, y);
        ctx.scale(1 / win.scale, 1 / win.scale);
        ctx.rotate(-center.angle);
        ctx.fillStyle = tank.color;
        ctx.font = Render.STAT_FONT;
        ctx.shadowColor = Render.STAT_SHADOW_COLOR;
        ctx.shadowBlur = Render.STAT_SHADOW_BLUR;
        ctx.textBaseline = "bottom";
        ctx.textAlign = "center";
        ctx.fillText(name, 0, -tank.radius * win.scale - Render.NAME_TAG_MARGIN);
        ctx.restore();
      }
      return void 0;
    };
    Render.map = function(ctx, game, win, center) {
      var east, north, radius, renderSquare, south, west, x, y, _i, _j, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      if (game.rotateViewport) {
        radius = 0.5 * Math.sqrt(win.w * win.w + win.h * win.h);
        west = center.x - radius / win.scale;
        east = center.x + radius / win.scale;
        north = center.y - radius / win.scale;
        south = center.y + radius / win.scale;
      } else {
        _ref = Render.winToMap(win, center, {
          x: 0,
          y: 0
        }), west = _ref.x, north = _ref.y;
        _ref1 = Render.winToMap(win, center, {
          x: win.w,
          y: win.h
        }), east = _ref1.x, south = _ref1.y;
      }
      renderSquare = function(x, y) {
        var square;
        square = Map.contains(game.map, x, y) ? Map.get(game.map, x, y) : Map.VOID;
        ctx.fillStyle = Map.squares[square].color;
        return ctx.fillRect(x, y, 1, 1);
      };
      for (x = _i = _ref2 = Math.floor(west), _ref3 = Math.floor(east); _i <= _ref3; x = _i += 1) {
        for (y = _j = _ref4 = Math.floor(north), _ref5 = Math.floor(south); _j <= _ref5; y = _j += 1) {
          renderSquare(x, y);
        }
      }
      return void 0;
    };
    Render.mapToWin = function(win, center, m) {
      return {
        x: win.scale * (m.x - center.x) + win.w * 0.5,
        y: win.scale * (m.y - center.y) + win.h * 0.5
      };
    };
    Render.winToMap = function(win, center, w) {
      return {
        x: center.x + (w.x - win.w * 0.5) / win.scale,
        y: center.y + (w.y - win.h * 0.5) / win.scale
      };
    };
    Render.stats = function(ctx, game, tank, win) {
      var coreStat, gameStat, info, startY, weapon, weaponStat;
      info = game.playerInfos[tank.index];
      weapon = tank.weapons[tank.activeWeapon];
      coreStat = "E " + (Math.floor(tank.energy)) + " M " + (Math.floor(tank.mass)) + " ";
      weaponStat = "" + weapon.spec.name + " " + (Math.ceil(weapon.temperature * 10));
      gameStat = ("-" + info.destroyed + "/+" + info.hits + "  ") + (function() {
        switch (game.mode.mode) {
          case "time":
            return "" + (Math.max(0, Math.floor(game.mode.time - game.time))) + " s";
          case "lives":
            return "" + (game.mode.lives - info.destroyed) + "/" + game.mode.lives + " lives";
          case "hits":
            return "" + info.hits + "/" + game.mode.hits + " hits";
        }
      })();
      ctx.save();
      ctx.font = Render.STAT_FONT;
      ctx.fillStyle = tank.color;
      ctx.shadowColor = Render.STAT_SHADOW_COLOR;
      ctx.shadowBlur = Render.STAT_SHADOW_BLUR;
      if (game.useHud) {
        ctx.textBaseline = "top";
        ctx.textAlign = "center";
        startY = win.h / 2 + tank.radius * win.scale + Render.HUD_MARGIN;
        ctx.fillText(coreStat, win.w / 2, startY);
        ctx.fillText(weaponStat, win.w / 2, startY + Render.HUD_ROW);
        ctx.fillText(gameStat, win.w / 2, startY + 2 * Render.HUD_ROW);
      } else {
        ctx.textBaseline = "bottom";
        ctx.textAlign = "left";
        ctx.fillText(weaponStat, Render.STAT_MARGIN, win.h - Render.STAT_MARGIN);
        ctx.textAlign = "center";
        ctx.fillText(coreStat, win.w / 2, win.h - Render.STAT_MARGIN);
        ctx.textAlign = "right";
        ctx.fillText(gameStat, win.w - Render.STAT_MARGIN, win.h - Render.STAT_MARGIN);
      }
      return ctx.restore();
    };
    return Render;
  });

}).call(this);
