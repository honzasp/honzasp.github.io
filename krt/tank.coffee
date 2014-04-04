define ["map", "bullet"], (Map, Bullet) ->
  Tank = {}
  Tank.RADIUS = 0.45
  Tank.WALL_DISTANCE = 0.01
  Tank.MASS = 100
  Tank.FORCE = 1000
  Tank.FRICTION = 100
  Tank.ANGULAR_SPEED = 1.5*Math.PI
  Tank.BUMP_FACTOR = 0.3
  Tank.BULLET_SPEED = 100
  Tank.BULLET_TIME = 2
  Tank.BULLET_DIST = 1.1

  Tank.init = (x, y, angle = 0) ->
    pos: {x, y}
    angle: angle
    vel: {x: 0, y: 0}
    acc: 0
    rot: 0

  Tank.fire = (tank, game) ->
    pos =
      x: tank.pos.x + Math.sin(tank.angle) * Tank.RADIUS * Tank.BULLET_DIST
      y: tank.pos.y + Math.cos(tank.angle) * Tank.RADIUS * Tank.BULLET_DIST
    relVel =
      x: Math.sin(tank.angle) * Tank.BULLET_SPEED
      y: Math.cos(tank.angle) * Tank.BULLET_SPEED
    vel = 
      x: relVel.x + tank.vel.x
      y: relVel.y + tank.vel.y
    game.bullets.push(Bullet.init(pos, vel, Tank.BULLET_TIME))
    Tank.impulse(tank, x: -relVel.x * Bullet.MASS, y: -relVel.y * Bullet.MASS)

  Tank.impulse = (tank, imp) ->
    tank.vel.x += imp.x / Tank.MASS
    tank.vel.y += imp.y / Tank.MASS

  Tank.move = (tank, t) ->
    force =
      x: -tank.vel.x * Tank.FRICTION + tank.acc * Math.sin(tank.angle) * Tank.FORCE
      y: -tank.vel.y * Tank.FRICTION + tank.acc * Math.cos(tank.angle) * Tank.FORCE
    tank.vel.x += force.x * t / Tank.MASS
    tank.vel.y += force.y * t / Tank.MASS
    tank.pos.x += tank.vel.x * t
    tank.pos.y += tank.vel.y * t
    tank.angle += tank.rot * Tank.ANGULAR_SPEED * t


  Tank.draw = (tank, ctx) ->
    ctx.save()
    ctx.translate(tank.pos.x, tank.pos.y)
    ctx.rotate(-tank.angle)
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
