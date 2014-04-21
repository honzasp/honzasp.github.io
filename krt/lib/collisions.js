// Generated by CoffeeScript 1.6.3
(function() {
  define(["exports", "map", "tank", "bullet", "particle", "weapon", "bonus", "update"], function(exports, Map, Tank, Bullet, Particle, Weapon, Bonus, Update) {
    var Collisions, lineMap, lineTank, solveQuad;
    Collisions = exports;
    Collisions.tankMap = function(game, tank) {
      var corner, edgeE, edgeN, edgeS, edgeW, imp, isFull, map, momentum, pos, r, x, y, _i, _j, _ref, _ref1, _ref2, _ref3;
      pos = {
        x: tank.pos.x,
        y: tank.pos.y
      };
      momentum = {
        x: tank.momentum.x,
        y: tank.momentum.y
      };
      r = tank.radius;
      map = game.map;
      imp = 0;
      edgeW = function(x, y) {
        if (y < pos.y && pos.y < y + 1 && pos.x < x && pos.x + r > x) {
          pos.x = x - r - Tank.WALL_DISTANCE;
          momentum.x *= -Tank.BUMP_FACTOR;
          return imp += Math.abs(momentum.x) * (1 + Tank.BUMP_FACTOR);
        }
      };
      edgeE = function(x, y) {
        if (y < pos.y && pos.y < y + 1 && pos.x > x && pos.x - r < x) {
          pos.x = x + r + Tank.WALL_DISTANCE;
          momentum.x *= -Tank.BUMP_FACTOR;
          return imp += Math.abs(momentum.x) * (1 + Tank.BUMP_FACTOR);
        }
      };
      edgeN = function(x, y) {
        if (x < pos.x && pos.x < x + 1 && pos.y < y && pos.y + r > y) {
          pos.y = y - r - Tank.WALL_DISTANCE;
          momentum.y *= -Tank.BUMP_FACTOR;
          return imp += Math.abs(momentum.y) * (1 + Tank.BUMP_FACTOR);
        }
      };
      edgeS = function(x, y) {
        if (x < pos.x && pos.x < x + 1 && pos.y > y && pos.y - r < y) {
          pos.y = y + r + Tank.WALL_DISTANCE;
          momentum.y *= -Tank.BUMP_FACTOR;
          return imp += Math.abs(momentum.y) * (1 + Tank.BUMP_FACTOR);
        }
      };
      corner = function(x, y, isNorth, isWest) {
        var d;
        d = {
          x: x - pos.x,
          y: y - pos.y
        };
        if (d.x * d.x + d.y * d.y < r * r) {
          momentum.x *= -Tank.BUMP_FACTOR;
          momentum.y *= -Tank.BUMP_FACTOR;
          imp += (Math.abs(momentum.x) + Math.abs(momentum.y)) * (1 + Tank.BUMP_FACTOR);
          if (isNorth) {
            if (isWest) {
              pos.x += d.x - Math.sqrt(r * r - d.y * d.y);
              return pos.y += d.y - Math.sqrt(r * r - d.x * d.x);
            } else {
              pos.x += d.x + Math.sqrt(r * r - d.y * d.y);
              return pos.y += d.y - Math.sqrt(r * r - d.x * d.x);
            }
          } else {
            if (isWest) {
              pos.x += d.x - Math.sqrt(r * r - d.y * d.y);
              return pos.y += d.y + Math.sqrt(r * r - d.x * d.x);
            } else {
              pos.x += d.x + Math.sqrt(r * r - d.y * d.y);
              return pos.y += d.y + Math.sqrt(r * r - d.x * d.x);
            }
          }
        }
      };
      isFull = function(x, y) {
        return !Map.contains(map, x, y) || Map.get(map, x, y) !== Map.EMPTY;
      };
      for (x = _i = _ref = Math.floor(pos.x - r), _ref1 = Math.floor(pos.x + r); _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; x = _ref <= _ref1 ? ++_i : --_i) {
        for (y = _j = _ref2 = Math.floor(pos.y - r), _ref3 = Math.floor(pos.y + r); _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; y = _ref2 <= _ref3 ? ++_j : --_j) {
          if (isFull(x, y)) {
            edgeW(x, y);
            edgeE(x + 1, y);
            edgeN(x, y);
            edgeS(x, y + 1);
            corner(x, y, true, true);
            corner(x + 1, y, true, false);
            corner(x, y + 1, false, true);
            corner(x + 1, y + 1, false, false);
          }
        }
      }
      tank.pos = pos;
      tank.momentum = momentum;
      if (imp !== 0) {
        return Update.tankMapHit(game, tank, imp);
      }
    };
    Collisions.tankTank = function(game, tank1, tank2) {
      var d, l, mom1, mom2, momD1, momD2, r1, r2, u;
      d = {
        x: tank1.pos.x - tank2.pos.x,
        y: tank1.pos.y - tank2.pos.y
      };
      l = Math.sqrt(d.x * d.x + d.y * d.y);
      r1 = tank1.radius;
      r2 = tank2.radius;
      if (l < r1 + r2) {
        u = {
          x: d.x / l,
          y: d.y / l
        };
        tank1.pos = {
          x: tank1.pos.x + u.x * (r1 - l / 2),
          y: tank1.pos.y + u.y * (r1 - l / 2)
        };
        tank2.pos = {
          x: tank2.pos.x - u.x * (r2 - l / 2),
          y: tank2.pos.y - u.y * (r2 - l / 2)
        };
        mom1 = tank1.momentum;
        mom2 = tank2.momentum;
        momD1 = mom1.x * u.x + mom1.y * u.y;
        momD2 = mom2.x * u.x + mom2.y * u.y;
        tank1.momentum = {
          x: mom1.x + u.x * (momD2 - momD1),
          y: mom1.y + u.y * (momD2 - momD1)
        };
        tank2.momentum = {
          x: mom2.x + u.x * (momD1 - momD2),
          y: mom2.y + u.y * (momD1 - momD2)
        };
        return Update.tankTankHit(game, tank1, tank2, Math.abs(momD1) + Math.abs(momD2));
      }
    };
    lineMap = function(start, end, map) {
      var eastEdges, hit, northEdges, southEdges, wallHit, westEdges;
      wallHit = null;
      hit = function(x, y, mapX, mapY, d) {
        if (!(d >= 0)) {
          return;
        }
        if (!(mapX >= 0 && mapX < map.width && mapY >= 0 && mapY < map.height)) {
          return wallHit = {
            d: Infinity,
            pos: {
              x: x,
              y: y
            }
          };
        } else {
          if (Map.get(map, mapX, mapY) === Map.EMPTY) {
            return;
          }
          if (!wallHit || d < wallHit.d) {
            return wallHit = {
              d: d,
              pos: {
                x: x,
                y: y
              },
              map: {
                x: mapX,
                y: mapY
              }
            };
          }
        }
      };
      hit(start.x, start.y, Math.floor(start.x), Math.floor(start.y), 0);
      northEdges = function() {
        var d, x, y;
        y = Math.ceil(start.y);
        while (y < Math.ceil(end.y)) {
          d = (y - start.y) / (end.y - start.y);
          x = start.x + (end.x - start.x) * d;
          hit(x, y, Math.floor(x), y, d);
          y = y + 1;
        }
        return void 0;
      };
      southEdges = function() {
        var d, x, y;
        y = Math.floor(start.y) - 1;
        while (y > Math.floor(end.y)) {
          d = (start.y - y - 1) / (start.y - end.y);
          x = start.x + (end.x - start.x) * d;
          hit(x, y + 1, Math.floor(x), y, d);
          y = y - 1;
        }
        return void 0;
      };
      westEdges = function() {
        var d, x, y;
        x = Math.ceil(start.x);
        while (x < Math.ceil(end.x)) {
          d = (x - start.x) / (end.x - start.x);
          y = start.y + (end.y - start.y) * d;
          hit(x + 1, y, x, Math.floor(y), d);
          x = x + 1;
        }
        return void 0;
      };
      eastEdges = function() {
        var d, x, y;
        x = Math.floor(start.x) - 1;
        while (x > Math.floor(end.x)) {
          d = (start.x - x - 1) / (start.x - end.x);
          y = start.y + (end.y - start.y) * d;
          hit(x, y, x, Math.floor(y), d);
          x = x - 1;
        }
        return void 0;
      };
      northEdges();
      southEdges();
      westEdges();
      eastEdges();
      return wallHit;
    };
    lineTank = function(start, end, tank) {
      var d, ds, e, p, r, s;
      s = start;
      e = end;
      p = tank.pos;
      r = tank.radius;
      ds = solveQuad((e.x - s.x) * (e.x - s.x) + (e.y - s.y) * (e.y - s.y), 2 * (e.x - s.x) * (s.x - p.x) + 2 * (e.y - s.y) * (s.y - p.y), (s.x - p.x) * (s.x - p.x) + (s.y - p.y) * (s.y - p.y) - r * r);
      ds = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = ds.length; _i < _len; _i++) {
          d = ds[_i];
          if (d >= 0 && d <= 1) {
            _results.push(d);
          }
        }
        return _results;
      })();
      d = ds.length === 2 ? Math.min(ds[0], ds[1]) : ds.length === 1 ? ds[0] : void 0;
      if (d != null) {
        return {
          d: d,
          pos: {
            x: s.x + d * (e.x - s.x),
            y: s.y + d * (e.y - s.y)
          },
          tank: tank
        };
      }
    };
    solveQuad = function(a, b, c) {
      var disc, discSqrt;
      disc = b * b - 4 * a * c;
      if (disc > 0) {
        discSqrt = Math.sqrt(disc);
        return [(-b - discSqrt) / (2 * a), (-b + discSqrt) / (2 * a)];
      } else if (disc === 0) {
        return [-b / (2 * a)];
      } else {
        return [];
      }
    };
    Collisions.bullet = function(game, bullet, t) {
      var end, map, nearestHit, start, tank, tankHit, tanks, _i, _len;
      tanks = game.tanks, map = game.map;
      start = {
        x: bullet.pos.x,
        y: bullet.pos.y
      };
      end = {
        x: bullet.pos.x + bullet.vel.x * t,
        y: bullet.pos.y + bullet.vel.y * t
      };
      if (Math.abs(end.x - start.x) < 0.001) {
        end.x = end.x + 0.001;
      }
      if (Math.abs(end.y - start.y) < 0.001) {
        end.y = end.y + 0.001;
      }
      nearestHit = lineMap(start, end, map);
      for (_i = 0, _len = tanks.length; _i < _len; _i++) {
        tank = tanks[_i];
        if (tankHit = lineTank(start, end, tank)) {
          if ((nearestHit == null) || tankHit.d < nearestHit.d) {
            nearestHit = tankHit;
          }
        }
      }
      if (nearestHit != null) {
        Update.bulletHit(game, bullet, nearestHit);
      }
      return void 0;
    };
    Collisions.bonus = function(game, bonus) {
      var dx, dy, l, tank, _i, _len, _ref;
      _ref = game.tanks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tank = _ref[_i];
        dx = tank.pos.x - bonus.pos.x;
        dy = tank.pos.y - bonus.pos.y;
        l = Math.sqrt(dx * dx + dy * dy);
        if (l < bonus.radius + tank.radius) {
          Update.bonusHit(game, bonus, tank);
          break;
        }
      }
      return void 0;
    };
    return Collisions;
  });

}).call(this);
