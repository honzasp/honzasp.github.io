define ["particle"], (Particle) ->
  Bullet = (@pos, @vel, @time) ->
    @isDead = false

  Bullet.RADIUS = 0.1
  Bullet.DESTROY_PROB = 0.2
  Bullet.MASS = 2
  Bullet.DAMAGE = 60

  Bullet::move = Particle::move

  Bullet::draw = (ctx) ->
    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, Bullet.RADIUS, 0, 2*Math.PI)
    ctx.fillStyle = "#f00"
    ctx.fill()

  Bullet
