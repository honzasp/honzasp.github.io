define ["map", "bullet", "game"], (Map, Bullet, Game) ->
  Tank = (idx, x, y, angle = 0) ->
    @index = idx
    @pos = {x, y}
    @angle = angle
    @vel = {x: 0, y: 0}
    @acc = 0
    @rot = 0
    @energy = Tank.MAX_ENERGY
    @matter = Tank.MAX_MATTER

  Tank.RADIUS = 0.45
  Tank.WALL_DISTANCE = 0.01
  Tank.MASS = 100
  Tank.FORCE = 1000
  Tank.FRICTION = 100
  Tank.ANGULAR_SPEED = 1.5*Math.PI
  Tank.BUMP_FACTOR = 0.3
  Tank.BULLET_SPEED = 100
  Tank.BULLET_TIME = 2
  Tank.BULLET_DIST = 1.2
  Tank.MAX_ENERGY = 100
  Tank.MAX_MATTER = 100

  Tank::fire = (game) ->
    pos =
      x: @pos.x + Math.sin(@angle) * Tank.RADIUS * Tank.BULLET_DIST
      y: @pos.y + Math.cos(@angle) * Tank.RADIUS * Tank.BULLET_DIST
    relVel =
      x: Math.sin(@angle) * Tank.BULLET_SPEED
      y: Math.cos(@angle) * Tank.BULLET_SPEED
    vel = 
      x: relVel.x + @vel.x
      y: relVel.y + @vel.y
    game.bullets.push(new Bullet(pos, vel, Tank.BULLET_TIME, @index))
    @impulse(x: -relVel.x * Bullet.MASS, y: -relVel.y * Bullet.MASS)

  Tank::damage = (game, dmg, guilty = undefined) ->
    if @energy > dmg
      @energy -= dmg
    else
      @energy = 0
      Game.tankDestroyed(game, @index, guilty)

  Tank::impulse = (imp) ->
    @vel.x += imp.x / Tank.MASS
    @vel.y += imp.y / Tank.MASS

  Tank::move = (t) ->
    forceX = -@vel.x * Tank.FRICTION + @acc * Math.sin(@angle) * Tank.FORCE
    forceY = -@vel.y * Tank.FRICTION + @acc * Math.cos(@angle) * Tank.FORCE
    @vel.x += forceX * t / Tank.MASS
    @vel.y += forceY * t / Tank.MASS
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t
    @angle += @rot * Tank.ANGULAR_SPEED * t

  Tank::draw = (ctx) ->
    ctx.save()
    ctx.translate(@pos.x, @pos.y)
    ctx.rotate(-@angle)
    ctx.scale(Tank.RADIUS, Tank.RADIUS)

    ctx.beginPath()
    ctx.arc(0, 0, 1.0, 0, Math.PI*2)
    ctx.fillStyle = "#833"
    ctx.fill()

    ctx.beginPath()
    ctx.moveTo( 0.0,  0.6)
    ctx.lineTo(-0.4, -0.4)
    ctx.lineTo( 0.4, -0.4)
    ctx.lineTo( 0.0,  0.6)
    ctx.fillStyle = "#333"
    ctx.fill()

    ctx.restore()

  Tank
