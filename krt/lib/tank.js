// Generated by CoffeeScript 1.6.3
(function() {
  define(["map", "weapon", "bullet", "game", "audio"], function(Map, Weapon, Bullet, Game, Audio) {
    var Tank;
    Tank = function(idx, x, y, angle, color, hum) {
      this.index = idx;
      this.pos = {
        x: x,
        y: y
      };
      this.angle = angle;
      this.vel = {
        x: 0,
        y: 0
      };
      this.acc = 0;
      this.rot = 0;
      this.firing = false;
      this.exploding = void 0;
      this.destroyedBy = void 0;
      this.isDead = false;
      this.weapons = [new Weapon(Weapon.MachineGun), new Weapon(Weapon.MiningGun), new Weapon(Weapon.EmergencyGun), new Weapon(Weapon.Autocannon), new Weapon(Weapon.HugeCannon)];
      this.activeWeapon = 0;
      this.color = color;
      this.hum = hum;
      this.setEnergy(Tank.START_ENERGY);
      this.setMass(Tank.START_MASS);
      return this;
    };
    Tank.WALL_DISTANCE = 0.01;
    Tank.FORCE = 1500;
    Tank.FRICTION = 100;
    Tank.ANGULAR_SPEED = 1.5 * Math.PI;
    Tank.FIRING_ANGULAR_SPEED = 0.5 * Math.PI;
    Tank.BUMP_FACTOR = 0.5;
    Tank.BULLET_DIST = 1.2;
    Tank.START_ENERGY = 1000;
    Tank.START_MASS = 100;
    Tank.DENSITY = 120;
    Tank.MIN_FIRE_ENERGY = 10;
    Tank.VISION_ENERGY = 400;
    Tank.MIN_MASS = 50;
    Tank.EXPLODING_TIME = 3;
    Tank.ENERGY_DRAIN = function(tank) {
      if (tank.acc !== 0 || tank.rot !== 0) {
        return 7 + tank.energy * 0.002;
      } else {
        return 1 + tank.energy * 0.002;
      }
    };
    Tank.HUM_GAIN = function(speed) {
      return 0.4 * (1.1 - Math.pow(0.9, speed / 5));
    };
    Tank.HUM_PLAYBACK = function(speed) {
      return 0.5 + Math.pow(1.1, speed / 10);
    };
    Tank.HIT_SOUND_GAIN = function(impulse) {
      return 0.8 * (1 - Math.pow(0.97, impulse / 12));
    };
    Tank.DAMAGE_SOUND_GAIN = function(dmg) {
      return 0.9 * (1 - Math.pow(0.65, dmg / 20));
    };
    Tank.prototype.change = function() {
      return this.activeWeapon = (this.activeWeapon + 1) % this.weapons.length;
    };
    Tank.prototype.fire = function(game) {
      var angle, posX, posY, relVelX, relVelY, spec, weapon;
      spec = (weapon = this.weapons[this.activeWeapon]).spec;
      if (!(weapon.temperature <= 0)) {
        return;
      }
      if (!(this.mass - spec.bullet.mass >= Tank.MIN_MASS)) {
        return;
      }
      if (!(this.energy - spec.energy >= Tank.MIN_FIRE_ENERGY)) {
        return;
      }
      angle = this.angle + (2 * spec.angleVariance * Math.random()) - spec.angleVariance;
      posX = this.pos.x + Math.sin(angle) * this.radius * Tank.BULLET_DIST;
      posY = this.pos.y + Math.cos(angle) * this.radius * Tank.BULLET_DIST;
      relVelX = Math.sin(angle) * spec.bullet.speed;
      relVelY = Math.cos(angle) * spec.bullet.speed;
      game.bullets.push(new Bullet({
        x: posX,
        y: posY
      }, {
        x: this.vel.x + relVelX,
        y: this.vel.y + relVelY
      }, spec.bullet, this.index));
      weapon.temperature = spec.cooldown;
      this.setMass(this.mass - spec.bullet.mass, game);
      this.setEnergy(this.energy - spec.energy, game);
      this.impulse({
        x: -relVelX * spec.bullet.mass,
        y: -relVelY * spec.bullet.mass
      });
      return Audio.sound(game, spec.sound, Weapon.FIRE_SOUND_GAIN);
    };
    Tank.prototype.hurt = function(game, dmg, guilty) {
      if (guilty == null) {
        guilty = void 0;
      }
      return this.setEnergy(this.energy - dmg, game, guilty);
    };
    Tank.prototype.receive = function(game, content) {
      if (content.energy != null) {
        this.setEnergy(this.energy + content.energy, game);
      }
      if (content.mass != null) {
        return this.setMass(this.mass + content.mass, game);
      }
    };
    Tank.prototype.setEnergy = function(energy, game, guilty) {
      if (guilty == null) {
        guilty = void 0;
      }
      if (energy < 0) {
        this.energy = 0;
        return this.destroy(game, guilty);
      } else {
        return this.energy = energy;
      }
    };
    Tank.prototype.setMass = function(mass, game, guilty) {
      if (guilty == null) {
        guilty = void 0;
      }
      this.mass = mass;
      this.radius = Math.sqrt(this.mass / Tank.DENSITY / Math.PI);
      if (mass < Tank.MIN_MASS) {
        return this.destroy(game, guilty);
      }
    };
    Tank.prototype.destroy = function(game, guilty) {
      var boom;
      if (this.exploding == null) {
        Game.tankDestroyed(game, this.index, guilty);
        boom = {
          count: 50,
          speed: 40,
          time: 1.5,
          radius: 1.2,
          color: this.color,
          opacity: 0.6,
          sound: "boom_tank"
        };
        Game.boom(game, this.pos, boom);
        return this.exploding = Tank.EXPLODING_TIME;
      }
    };
    Tank.prototype.impulse = function(imp) {
      this.vel.x += imp.x / this.mass;
      return this.vel.y += imp.y / this.mass;
    };
    Tank.prototype.update = function(game, t) {
      var forceX, forceY, speed, time, weapon, _i, _len, _ref;
      _ref = this.weapons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        weapon = _ref[_i];
        if (weapon.temperature > 0) {
          weapon.temperature -= t;
        }
      }
      if (this.exploding != null) {
        this.exploding -= t;
        this.isDead || (this.isDead = this.exploding < 0);
        this.acc = 0;
        this.rot = 0;
      }
      this.pos.x += this.vel.x * t;
      this.pos.y += this.vel.y * t;
      forceX = -this.vel.x * Tank.FRICTION + this.acc * Math.sin(this.angle) * Tank.FORCE;
      forceY = -this.vel.y * Tank.FRICTION + this.acc * Math.cos(this.angle) * Tank.FORCE;
      this.vel.x += forceX * t / this.mass;
      this.vel.y += forceY * t / this.mass;
      if (this.firing) {
        this.angle += this.rot * Tank.FIRING_ANGULAR_SPEED * t;
        this.fire(game);
      } else {
        this.angle += this.rot * Tank.ANGULAR_SPEED * t;
      }
      if (this.hum != null) {
        time = Audio.currentTime(game);
        speed = Math.sqrt(this.vel.x * this.vel.x + this.vel.y * this.vel.y);
        this.hum.gainNode.gain.value = Tank.HUM_GAIN(speed);
        this.hum.sourceNode.playbackRate.value = Tank.HUM_PLAYBACK(speed);
      }
      return this.setEnergy(this.energy - Tank.ENERGY_DRAIN(this) * t, game);
    };
    Tank.prototype.render = function(ctx) {
      ctx.save();
      ctx.translate(this.pos.x, this.pos.y);
      ctx.rotate(-this.angle);
      ctx.scale(this.radius, this.radius);
      ctx.beginPath();
      ctx.arc(0, 0, 1.0, 0, Math.PI * 2);
      if (this.exploding != null) {
        ctx.globalAlpha *= 0.2;
      }
      ctx.fillStyle = this.color;
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
  });

}).call(this);
