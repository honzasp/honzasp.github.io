// Generated by CoffeeScript 1.6.3
(function() {
  define(["map"], function(Map) {
    var Window;
    return Window = (function() {
      function Window(game, center, dim) {
        this.game = game;
        this.center = center;
        this.dim = dim;
        this.ctx = this.game.ctx;
        this.ctx.save();
        this.ctx.translate(this.dim.x, this.dim.y);
        this.ctx.beginPath();
        this.ctx.rect(0, 0, this.dim.w, this.dim.h);
        this.ctx.clip();
        this.drawTiles();
        this.drawObjects();
        this.ctx.restore();
      }

      Window.prototype.drawTiles = function() {
        var east, north, south, west, x, y, _i, _j, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
        _ref = this.winToMap({
          x: 0,
          y: 0
        }), west = _ref.x, north = _ref.y;
        _ref1 = this.winToMap({
          x: this.dim.w,
          y: this.dim.h
        }), east = _ref1.x, south = _ref1.y;
        for (x = _i = _ref2 = Math.floor(west), _ref3 = Math.ceil(east); _ref2 <= _ref3 ? _i <= _ref3 : _i >= _ref3; x = _ref2 <= _ref3 ? ++_i : --_i) {
          for (y = _j = _ref4 = Math.floor(north), _ref5 = Math.ceil(south); _ref4 <= _ref5 ? _j <= _ref5 : _j >= _ref5; y = _ref4 <= _ref5 ? ++_j : --_j) {
            this.drawTile({
              x: x,
              y: y
            });
          }
        }
        return void 0;
      };

      Window.prototype.drawObjects = function() {
        var i, _i, _j, _ref, _ref1;
        this.ctx.save();
        this.ctx.translate(this.dim.w * 0.5, this.dim.h * 0.5);
        this.ctx.scale(this.dim.scale, this.dim.scale);
        this.ctx.translate(-this.center.x, -this.center.y);
        for (i = _i = 0, _ref = this.game.tanks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          this.game.tanks[i].draw(this.ctx);
        }
        for (i = _j = 0, _ref1 = this.game.bullets.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          if (!this.game.bullets[i].isDead) {
            this.game.bullets[i].draw(this.ctx);
          }
        }
        return this.ctx.restore();
      };

      Window.prototype.drawTile = function(pos) {
        var winPos;
        winPos = this.mapToWin(pos);
        this.ctx.fillStyle = this.tileColor(this.game.map.get(pos.x, pos.y));
        return this.ctx.fillRect(winPos.x, winPos.y, this.dim.scale + 0.5, this.dim.scale + 0.5);
      };

      Window.prototype.tileColor = function(tile) {
        switch (tile) {
          case Map.EMPTY:
            return "#333";
          case Map.ROCK:
            return "#aaa";
          case Map.CONCRETE:
            return "#ccc";
          case Map.VOID:
            return "#000";
          default:
            return "#f00";
        }
      };

      Window.prototype.mapToWin = function(m) {
        return {
          x: this.dim.scale * (m.x - this.center.x) + this.dim.w * 0.5,
          y: this.dim.scale * (m.y - this.center.y) + this.dim.h * 0.5
        };
      };

      Window.prototype.winToMap = function(w) {
        return {
          x: this.center.x + (w.x - this.dim.w * 0.5) / this.dim.scale,
          y: this.center.y + (w.y - this.dim.h * 0.5) / this.dim.scale
        };
      };

      Window.prototype.drawCircle = function(pos, radius) {
        var winPos, winRadius;
        winPos = this.mapToWin(pos);
        winRadius = radius * this.dim.scale;
        this.ctx.beginPath();
        this.ctx.fillStyle = "#f00";
        this.ctx.arc(winPos.x, winPos.y, winRadius, 0, Math.PI * 2);
        return this.ctx.fill();
      };

      return Window;

    })();
  });

}).call(this);
