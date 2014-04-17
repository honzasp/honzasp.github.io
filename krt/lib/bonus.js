// Generated by CoffeeScript 1.6.3
(function() {
  define([], function() {
    var Bonus;
    Bonus = function(pos, vel, content, radiusSinVel) {
      this.pos = pos;
      this.vel = vel;
      this.content = content;
      this.radiusSinVel = radiusSinVel;
      this.isDead = false;
      return this.radiusAngle = this.radiusSinVel;
    };
    Bonus.ENERGY_LOSS = 5;
    Bonus.MASS_LOSS = 2;
    Bonus.ENERGY_COLORS = ["#2b9ad9", "#2b8ad9", "#2b78d9", "#2b60d9", "#2b4fd9"];
    Bonus.ENERGY_HALF_OPACITY = 50;
    Bonus.MASS_COLORS = ["#ddb94f", "#ddae4f", "#ddc94f", "#ddd14f"];
    Bonus.MASS_HALF_OPACITY = 20;
    Bonus.RADIUS_MID = 0.4;
    Bonus.RADIUS_AMP = 0.05;
    Bonus.SPEED = 0.3;
    Bonus.RADIUS_SIN_VEL = 2 * Math.PI * 1.3;
    Bonus.SOUND_GAIN = 0.6;
    Bonus.prototype.update = function(t) {
      this.pos.x += this.vel.x * t;
      this.pos.y += this.vel.y * t;
      this.radiusAngle += this.radiusSinVel * t;
      this.radius = Bonus.RADIUS_MID + Math.sin(this.radiusAngle) * Bonus.RADIUS_AMP;
      this.content.update(t);
      return this.isDead || (this.isDead = this.content.isEmpty());
    };
    Bonus.prototype.render = function(ctx) {
      ctx.save();
      ctx.fillStyle = this.content.color;
      ctx.globalAlpha *= this.content.getOpacity();
      ctx.beginPath();
      ctx.arc(this.pos.x, this.pos.y, this.radius, 0, 2 * Math.PI);
      ctx.fill();
      return ctx.restore();
    };
    Bonus.Energy = function(energy) {
      this.energy = energy;
      this.color = Bonus.ENERGY_COLORS[Math.floor(Bonus.ENERGY_COLORS.length * Math.random())];
      return this.getSound = "get_energy";
    };
    Bonus.Energy.prototype.update = function(t) {
      return this.energy -= Bonus.ENERGY_LOSS * t;
    };
    Bonus.Energy.prototype.isEmpty = function() {
      return this.energy <= 0;
    };
    Bonus.Energy.prototype.getOpacity = function() {
      return Math.pow(0.5, Bonus.ENERGY_HALF_OPACITY / this.energy);
    };
    Bonus.Mass = function(mass) {
      this.mass = mass;
      this.color = Bonus.MASS_COLORS[Math.floor(Bonus.MASS_COLORS.length * Math.random())];
      return this.getSound = "get_mass";
    };
    Bonus.Mass.prototype.update = function(t) {
      return this.mass -= Bonus.MASS_LOSS * t;
    };
    Bonus.Mass.prototype.isEmpty = function() {
      return this.mass <= 0;
    };
    Bonus.Mass.prototype.getOpacity = function() {
      return Math.pow(0.5, Bonus.MASS_HALF_OPACITY / this.mass);
    };
    return Bonus;
  });

}).call(this);
