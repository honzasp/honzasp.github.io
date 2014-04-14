// Generated by CoffeeScript 1.6.3
(function() {
  define([], function() {
    var Particle;
    Particle = function(opts) {
      this.pos = opts.pos;
      this.vel = opts.vel;
      this.time = opts.time;
      this.radius = opts.radius;
      this.radiusVel = opts.radiusVel || 0;
      this.color = opts.color;
      this.opacity = opts.opacity || 1;
      this.opacityVel = opts.opacityVel || 0;
      return this.isDead = false;
    };
    Particle.prototype.update = function(t) {
      this.time -= t;
      this.isDead || (this.isDead = this.time < 0);
      this.pos.x += this.vel.x * t;
      this.pos.y += this.vel.y * t;
      this.opacity += this.opacityVel * t;
      return this.radius += this.radiusVel * t;
    };
    Particle.prototype.render = function(ctx) {
      ctx.save();
      ctx.beginPath();
      ctx.arc(this.pos.x, this.pos.y, this.radius, 0, 2 * Math.PI);
      ctx.fillStyle = this.color;
      ctx.globalAlpha *= this.opacity;
      ctx.fill();
      return ctx.restore();
    };
    return Particle;
  });

}).call(this);
