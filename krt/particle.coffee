define [], () ->
  Particle = (@pos, @vel, @time, @radius, @color) ->
    @isDead = false

  Particle::move = (t) ->
    @time -= t
    @isDead ||= (@time < 0)
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t

  Particle::draw = (ctx) ->
    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @radius, 0, 2*Math.PI)
    ctx.fillStyle = @color
    ctx.fill()

  Particle
