define [], () ->
  Bullet = (@pos, @vel, @spec, @owner = undefined) ->
    @time = @spec.time
    @isDead = false

  Bullet::update = (t) ->
    @time -= t
    @isDead ||= (@time < 0)
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t

  Bullet::render = (ctx) ->
    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @spec.radius, 0, 2*Math.PI)
    ctx.fillStyle = @spec.color
    ctx.fill()

  Bullet
