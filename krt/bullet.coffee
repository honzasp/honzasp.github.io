define ["particle"], (Particle) ->
  Bullet = (@pos, @vel, @spec, @owner = undefined) ->
    @time = @spec.time
    @isDead = false

  Bullet::move = Particle::move

  Bullet::draw = (ctx) ->
    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @spec.radius, 0, 2*Math.PI)
    ctx.fillStyle = @spec.color
    ctx.fill()

  Bullet
