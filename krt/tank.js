// Generated by CoffeeScript 1.6.3
(function() {
  define(["map", "bullet"], function(Map, Bullet) {
    var Tank;
    return Tank = (function() {
      Tank.RADIUS = 0.45;

      Tank.WALL_DISTANCE = 0.01;

      Tank.MASS = 100;

      Tank.FORCE = 1000;

      Tank.FRICTION = 100;

      Tank.ANGULAR_SPEED = 1.5 * Math.PI;

      Tank.BUMP_FACTOR = 0.3;

      Tank.BULLET_SPEED = 100;

      Tank.BULLET_TIME = 2;

      Tank.BULLET_DIST = 1.1;

      function Tank(game, pos, angle) {
        this.game = game;
        this.pos = pos;
        this.angle = angle != null ? angle : 0;
        this.vel = {
          x: 0,
          y: 0
        };
        this.acc = 0;
        this.rot = 0;
      }

      Tank.prototype.fire = function() {
        var pos, relVel, vel;
        pos = {
          x: this.pos.x + Math.sin(this.angle) * Tank.RADIUS * Tank.BULLET_DIST,
          y: this.pos.y + Math.cos(this.angle) * Tank.RADIUS * Tank.BULLET_DIST
        };
        relVel = {
          x: Math.sin(this.angle) * Tank.BULLET_SPEED,
          y: Math.cos(this.angle) * Tank.BULLET_SPEED
        };
        vel = {
          x: relVel.x + this.vel.x,
          y: relVel.y + this.vel.y
        };
        return this.game.bullets.push(new Bullet(this.game, pos, vel, Tank.BULLET_TIME));
      };

      Tank.prototype.impulse = function(imp) {
        return this.vel = {
          x: this.vel.x + imp.x / Tank.MASS,
          y: this.vel.y + imp.y / Tank.MASS
        };
      };

      Tank.prototype.update = function(t) {
        var force;
        force = {
          x: -this.vel.x * Tank.FRICTION + this.acc * Math.sin(this.angle) * Tank.FORCE,
          y: -this.vel.y * Tank.FRICTION + this.acc * Math.cos(this.angle) * Tank.FORCE
        };
        this.vel = {
          x: this.vel.x + force.x * t / Tank.MASS,
          y: this.vel.y + force.y * t / Tank.MASS
        };
        this.pos = {
          x: this.pos.x + this.vel.x * t,
          y: this.pos.y + this.vel.y * t
        };
        return this.angle = this.angle + this.rot * Tank.ANGULAR_SPEED * t;
      };

      Tank.prototype.draw = function(ctx) {
        ctx.save();
        ctx.translate(this.pos.x, this.pos.y);
        ctx.rotate(-this.angle);
        ctx.scale(Tank.RADIUS, Tank.RADIUS);
        ctx.beginPath();
        ctx.arc(0, 0, 1.0, 0, Math.PI * 2);
        ctx.fillStyle = "#833";
        ctx.fill();
        ctx.beginPath();
        ctx.moveTo(0.0, 0.6);
        ctx.lineTo(-0.4, -0.4);
        ctx.lineTo(0.4, -0.4);
        ctx.lineTo(0.0, 0.6);
        ctx.fillStyle = "#333";
        ctx.fill();
        return ctx.restore();
      };

      return Tank;

    })();
  });

}).call(this);
