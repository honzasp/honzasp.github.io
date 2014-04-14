// Generated by CoffeeScript 1.6.3
(function() {
  define([], function() {
    var Bullet;
    Bullet = function(pos, vel, spec, owner) {
      this.pos = pos;
      this.vel = vel;
      this.spec = spec;
      this.owner = owner != null ? owner : void 0;
      this.time = this.spec.time;
      return this.isDead = false;
    };
    Bullet.prototype.update = function(t) {
      this.time -= t;
      this.isDead || (this.isDead = this.time < 0);
      this.pos.x += this.vel.x * t;
      return this.pos.y += this.vel.y * t;
    };
    Bullet.prototype.render = function(ctx) {
      ctx.beginPath();
      ctx.arc(this.pos.x, this.pos.y, this.spec.radius, 0, 2 * Math.PI);
      ctx.fillStyle = this.spec.color;
      return ctx.fill();
    };
    return Bullet;
  });

}).call(this);