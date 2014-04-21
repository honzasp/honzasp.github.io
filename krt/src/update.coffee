"use strict"
define "exports  collisions  game  map  weapon  tank  bullet  particle  bonus  audio".split(/\s+/),\
       (exports, Collisions, Game, Map, Weapon, Tank, Bullet, Particle, Bonus, Audio) ->
  Update = exports

  Update.game = (game, t) ->
    Update.bullets(game, t)
    Update.particles(game, t)
    Update.bonuses(game, t)
    Update.tanks(game, t)
    game.time += t

  Update.tanks = (game, t) ->
    for i in [0...game.tanks.length] by 1
      game.tanks[i].update(game, t)
      if game.tanks[i].isDead
        game.tanks[i] = Game.createTank(game, game.playerInfos[i])

    for i in [0...game.tanks.length] by 1
      for j in [i+1...game.tanks.length] by 1
        Collisions.tankTank(game, game.tanks[i], game.tanks[j])

    for i in [0...game.tanks.length] by 1
      Collisions.tankMap(game, game.tanks[i])

    undefined

  Update.bullets = (game, t) ->
    Update.updateLive(game, game.bullets, (bullet) ->
      Collisions.bullet(game, bullet, t)
      bullet.update(t)
    )

  Update.particles = (game, t) ->
    Update.updateLive(game, game.particles, (particle) ->
      particle.update(t)
    )

  Update.bonuses = (game, t) ->
    Update.updateLive(game, game.bonuses, (bonus) ->
      Collisions.bonus(game, bonus)
      bonus.update(t)
    )

  Update.updateLive = (game, objs, update) ->
    dead = 0
    for obj in objs
      unless obj.isDead
        update(obj)
      else
        dead = dead + 1

    if dead > objs.length * Game.MAX_GARBAGE_RATIO
      p = 0
      for i in [0...objs.length] by 1
        unless objs[i].isDead
          objs[p] = objs[i]
          p = p + 1
      objs.length = p

  Update.bulletHit = (game, bullet, hit) ->
    bullet.isDead = true
    if hit.map?
      Update.bulletHit.map(game, bullet, hit)
    else if hit.tank?
      Update.bulletHit.tank(game, bullet, hit)
    Update.bulletHit.fragments(game, bullet, hit)
    Update.boom(game, hit.pos, bullet.spec.boom)

  Update.bulletHit.map = (game, bullet, hit) ->
    {toughness, energy, mass, prob, shotSound} = Map.squares[Map.get(game.map, hit.map.x, hit.map.y)]
    Audio.sound(game, shotSound, Map.SHOT_SOUND_GAIN) if shotSound?

    if Math.pow(toughness, bullet.spec.damage) < Math.random()
      Map.set(game.map, hit.map.x, hit.map.y, Map.EMPTY)

      content = 
        if !prob? or prob > Math.random()
          if energy? and ((mass? and Math.random() < 0.5) or not mass?)
            new Bonus.Energy(energy*(0.5 + Math.random()))
          else if mass?
            new Bonus.Mass(mass*(0.5 + Math.random()))
      if content?
        pos = { x: hit.map.x + 0.5, y: hit.map.y + 0.5 }
        angle = Math.random() * 2*Math.PI
        speed = Bonus.SPEED * (0.5 + Math.random())
        vel = { x: Math.sin(angle) * speed, y: Math.cos(angle) * speed }
        radiusSinVel = Bonus.RADIUS_SIN_VEL * (0.5 + Math.random())
        bonus = new Bonus(pos, vel, content, radiusSinVel)
        game.bonuses.push(bonus)
    undefined

  Update.bulletHit.tank = (game, bullet, hit) ->
    Audio.sound(game, "hit_tank", Tank.DAMAGE_SOUND_GAIN(bullet.spec.hurt))
    hit.tank.impulse(x: bullet.vel.x * bullet.spec.mass, y: bullet.vel.y * bullet.spec.mass)
    hit.tank.hurt(game, bullet.spec.hurt, bullet.owner)
    undefined

  Update.bulletHit.fragments = (game, bullet, hit) ->
    if (fragment = bullet.spec.fragment)?
      fragmentCount = Math.floor(bullet.spec.mass / fragment.mass)
      for i in [0...fragmentCount]
        angle = 2*Math.PI * Math.random()
        speed = fragment.speed * (0.7 + 0.6*Math.random())
        posX = Math.sin(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.x
        posY = Math.cos(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.y
        velX = Math.sin(angle) * speed
        velY = Math.cos(angle) * speed
        bullet = new Bullet(
          {x: hit.pos.x, y: hit.pos.y},
          {x: velX, y: velY},
          fragment, bullet.owner)
        game.bullets.push(bullet)
    undefined

  Update.bonusHit = (game, bonus, tank) ->
    tank.receive(game, bonus.content)
    bonus.isDead = true
    Audio.sound(game, bonus.content.getSound, Bonus.SOUND_GAIN)

  Update.tankTankHit = (game, tank1, tank2, impulse) ->
    Audio.sound(game, "hit_tank", Tank.HIT_SOUND_GAIN(impulse))

  Update.tankMapHit = (game, tank, impulse) ->
    Audio.sound(game, "hit_tank", Tank.HIT_SOUND_GAIN(impulse))

  Update.boom = (game, pos, spec) ->
    Audio.sound(game, spec.sound) if spec.sound?

    for i in [0...spec.count]
      angle   = 2*Math.PI * Math.random()
      speed   = spec.speed * (Math.random() + 0.5)
      time    = spec.time * (Math.random() + 0.5)
      radius  = spec.radius * (Math.random() + 0.5)
      radius2 = radius * (1 + Math.random() * 0.5)
      velX    = Math.sin(angle) * speed
      velY    = Math.cos(angle) * speed
      game.particles.push(new Particle({
        pos: {x: pos.x, y: pos.y}
        vel: {x: velX, y: velY}
        time, radius
        opacity: spec.opacity
        opacityVel: -spec.opacity / time
        radiusVel: (radius2 - radius) / time
        color: spec.color
      }))
    undefined

  Update
