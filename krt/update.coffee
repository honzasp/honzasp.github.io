define ["exports", "collisions", "game", "map", "weapon", "bullet", "bonus"],\
(exports, Collisions, Game, Map, Weapon, Bullet, Bonus) ->
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

    for i in [0...game.tanks.length] by 1
      for j in [i+1...game.tanks.length] by 1
        Collisions.tankTank(game.tanks[i], game.tanks[j])

    for i in [0...game.tanks.length] by 1
      Collisions.tankMap(game.tanks[i], game.map)

    undefined

  Update.bullets = (game, t) ->
    Update.updateLive(game, game.bullets, (bullet) ->
      Collisions.bullet(bullet, game, t)
      bullet.move(t)
    )

  Update.particles = (game, t) ->
    Update.updateLive(game, game.particles, (particle) ->
      particle.move(t)
    )

  Update.bonuses = (game, t) ->
    Update.updateLive(game, game.bonuses, (bonus) ->
      Collisions.bonus(bonus, game, t)
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
    bullet.spec.boom(game, hit.pos)

  Update.bulletHit.map = (game, bullet, hit) ->
    {toughness, energy, mass} = Map.squares[Map.get(game.map, hit.map.x, hit.map.y)]
    if Math.pow(toughness, bullet.spec.damage) < Math.random()
      Map.set(game.map, hit.map.x, hit.map.y, Map.EMPTY)
      gain = 
        if energy? and ((mass? and Math.random() < 0.5) or not mass?)
          energy: energy*(0.5 + Math.random())
        else if mass?
          mass: mass*(0.5 + Math.random())
      if gain?
        pos = { x: hit.map.x + 0.5, y: hit.map.y + 0.5 }
        angle = Math.random() * 2*Math.PI
        speed = Bonus.SPEED * (0.5 + Math.random())
        vel = { x: Math.sin(angle) * speed, y: Math.cos(angle) * speed }
        radiusSinVel = Bonus.RADIUS_SIN_VEL * (0.5 + Math.random())
        bonus = new Bonus(pos, vel, gain, radiusSinVel)
        game.bonuses.push(bonus)
    undefined

  Update.bulletHit.tank = (game, bullet, hit) ->
    hit.tank.impulse(x: bullet.vel.x * bullet.spec.mass, y: bullet.vel.y * bullet.spec.mass)
    hit.tank.damage(game, bullet.spec.damage, bullet.owner)
    undefined

  Update.bulletHit.fragments = (game, bullet, hit) ->
    if (fragment = bullet.spec.fragment)?
      fragmentCount = Math.floor(bullet.spec.mass / fragment.mass)
      for i in [0...fragmentCount]
        angle = 2*Math.PI * Math.random()
        posX = Math.sin(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.x
        posY = Math.cos(angle) * Weapon.FRAGMENT_RADIUS + hit.pos.y
        velX = Math.sin(angle) * fragment.speed
        velY = Math.cos(angle) * fragment.speed
        bullet = new Bullet(
          {x: hit.pos.x, y: hit.pos.y},
          {x: velX, y: velY},
          fragment, bullet.owner)
        game.bullets.push(bullet)
    undefined

  Update
