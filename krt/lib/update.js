// Generated by CoffeeScript 1.6.3
(function() {
  define("exports  collisions  game  map  weapon  tank  bullet  particle  bonus  audio".split(/\s+/), function(exports, Collisions, Game, Map, Weapon, Tank, Bullet, Particle, Bonus, Audio) {
    var Update;
    Update = exports;
    Update.game = function(game, t) {
      Update.bullets(game, t);
      Update.particles(game, t);
      Update.bonuses(game, t);
      Update.tanks(game, t);
      return game.time += t;
    };
    Update.tanks = function(game, t) {
      var i, j, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _ref4;
      for (i = _i = 0, _ref = game.tanks.length; _i < _ref; i = _i += 1) {
        game.tanks[i].update(game, t);
        if (game.tanks[i].isDead) {
          game.tanks[i] = Game.createTank(game, game.playerInfos[i]);
        }
      }
      for (i = _j = 0, _ref1 = game.tanks.length; _j < _ref1; i = _j += 1) {
        for (j = _k = _ref2 = i + 1, _ref3 = game.tanks.length; _k < _ref3; j = _k += 1) {
          Collisions.tankTank(game, game.tanks[i], game.tanks[j]);
        }
      }
      for (i = _l = 0, _ref4 = game.tanks.length; _l < _ref4; i = _l += 1) {
        Collisions.tankMap(game, game.tanks[i]);
      }
      return void 0;
    };
    Update.bullets = function(game, t) {
      return Update.updateLive(game, game.bullets, function(bullet) {
        Collisions.bullet(game, bullet, t);
        return bullet.update(t);
      });
    };
    Update.particles = function(game, t) {
      return Update.updateLive(game, game.particles, function(particle) {
        return particle.update(t);
      });
    };
    Update.bonuses = function(game, t) {
      return Update.updateLive(game, game.bonuses, function(bonus) {
        Collisions.bonus(game, bonus);
        return bonus.update(t);
      });
    };
    Update.updateLive = function(game, objs, update) {
      var dead, i, obj, p, _i, _j, _len, _ref;
      dead = 0;
      for (_i = 0, _len = objs.length; _i < _len; _i++) {
        obj = objs[_i];
        if (!obj.isDead) {
          update(obj);
        } else {
          dead = dead + 1;
        }
      }
      if (dead > objs.length * Game.MAX_GARBAGE_RATIO) {
        p = 0;
        for (i = _j = 0, _ref = objs.length; _j < _ref; i = _j += 1) {
          if (!objs[i].isDead) {
            objs[p] = objs[i];
            p = p + 1;
          }
        }
        return objs.length = p;
      }
    };
    Update.bulletHit = function(game, bullet, hit) {
      bullet.isDead = true;
      if (hit.map != null) {
        Update.bulletHit.map(game, bullet, hit);
      } else if (hit.tank != null) {
        Update.bulletHit.tank(game, bullet, hit);
      }
      Update.bulletHit.fragments(game, bullet, hit);
      return Update.boom(game, hit.pos, bullet.spec.boom);
    };
    Update.bulletHit.map = function(game, bullet, hit) {
      var angle, bonus, content, energy, mass, pos, prob, radiusSinVel, shotSound, speed, toughness, vel, _ref;
      _ref = Map.squares[Map.get(game.map, hit.map.x, hit.map.y)], toughness = _ref.toughness, energy = _ref.energy, mass = _ref.mass, prob = _ref.prob, shotSound = _ref.shotSound;
      if (shotSound != null) {
        Audio.sound(game, shotSound, Map.SHOT_SOUND_GAIN);
      }
      if (Math.pow(toughness, bullet.spec.damage) < Math.random()) {
        Map.set(game.map, hit.map.x, hit.map.y, Map.EMPTY);
        content = (prob == null) || prob > Math.random() ? (energy != null) && (((mass != null) && Math.random() < 0.5) || (mass == null)) ? new Bonus.Energy(energy * (0.5 + Math.random())) : mass != null ? new Bonus.Mass(mass * (0.5 + Math.random())) : void 0 : void 0;
        if (content != null) {
          pos = {
            x: hit.map.x + 0.5,
            y: hit.map.y + 0.5
          };
          angle = Math.random() * 2 * Math.PI;
          speed = Bonus.SPEED * (0.5 + Math.random());
          vel = {
            x: Math.sin(angle) * speed,
            y: Math.cos(angle) * speed
          };
          radiusSinVel = Bonus.RADIUS_SIN_VEL * (0.5 + Math.random());
          bonus = new Bonus(pos, vel, content, radiusSinVel);
          game.bonuses.push(bonus);
        }
      }
      return void 0;
    };
    Update.bulletHit.tank = function(game, bullet, hit) {
      Audio.sound(game, "hit_tank", Tank.DAMAGE_SOUND_GAIN(bullet.spec.hurt));
      hit.tank.impulse({
        x: bullet.vel.x * bullet.spec.mass,
        y: bullet.vel.y * bullet.spec.mass
      });
      hit.tank.hurt(game, bullet.spec.hurt, bullet.owner);
      return void 0;
    };
    Update.bulletHit.fragments = function(game, bullet, hit) {
      var angle, fragment, fragmentCount, i, posX, posY, velX, velY, _i;
      if ((fragment = bullet.spec.fragment) != null) {
        fragmentCount = Math.floor(bullet.spec.mass / fragment.mass);
        for (i = _i = 0; 0 <= fragmentCount ? _i < fragmentCount : _i > fragmentCount; i = 0 <= fragmentCount ? ++_i : --_i) {
          angle = 2 * Math.PI * Math.random();
          posX = Math.sin(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.x;
          posY = Math.cos(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.y;
          velX = Math.sin(angle) * fragment.speed;
          velY = Math.cos(angle) * fragment.speed;
          bullet = new Bullet({
            x: hit.pos.x,
            y: hit.pos.y
          }, {
            x: velX,
            y: velY
          }, fragment, bullet.owner);
          game.bullets.push(bullet);
        }
      }
      return void 0;
    };
    Update.bonusHit = function(game, bonus, tank) {
      tank.receive(game, bonus.content);
      bonus.isDead = true;
      return Audio.sound(game, bonus.content.getSound, Bonus.SOUND_GAIN);
    };
    Update.tankTankHit = function(game, tank1, tank2, impulse) {
      return Audio.sound(game, "hit_tank", Tank.HIT_SOUND_GAIN(impulse));
    };
    Update.tankMapHit = function(game, tank, impulse) {
      return Audio.sound(game, "hit_tank", Tank.HIT_SOUND_GAIN(impulse));
    };
    Update.boom = function(game, pos, spec) {
      var angle, i, radius, radius2, speed, time, velX, velY, _i, _ref;
      if (spec.sound != null) {
        Audio.sound(game, spec.sound);
      }
      for (i = _i = 0, _ref = spec.count; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        angle = 2 * Math.PI * Math.random();
        speed = spec.speed * (Math.random() + 0.5);
        time = spec.time * (Math.random() + 0.5);
        radius = spec.radius * (Math.random() + 0.5);
        radius2 = radius * (1 + Math.random() * 0.5);
        velX = Math.sin(angle) * speed;
        velY = Math.cos(angle) * speed;
        game.particles.push(new Particle({
          pos: {
            x: pos.x,
            y: pos.y
          },
          vel: {
            x: velX,
            y: velY
          },
          time: time,
          radius: radius,
          opacity: spec.opacity,
          opacityVel: -spec.opacity / time,
          radiusVel: (radius2 - radius) / time,
          color: spec.color
        }));
      }
      return void 0;
    };
    return Update;
  });

}).call(this);
