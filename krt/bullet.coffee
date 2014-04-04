define [], () ->
  Bullet = {}
  Bullet.RADIUS = 0.1
  Bullet.DESTROY_PROB = 0.2
  Bullet.MASS = 2

  Bullet.init = (pos, vel, time) ->
    { pos, vel, time, isDead: false }

  Bullet.move = (bullet, t) ->
    bullet.time -= t
    bullet.isDead ||= (bullet.time < 0)
    bullet.pos.x += bullet.vel.x * t
    bullet.pos.y += bullet.vel.y * t

  Bullet.draw = (bullet, ctx) ->
    ctx.beginPath()
    ctx.arc(bullet.pos.x, bullet.pos.y, Bullet.RADIUS, 0, 2*Math.PI)
    ctx.fillStyle = "#f00"
    ctx.fill()

  Bullet
