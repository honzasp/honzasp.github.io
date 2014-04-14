define [], () ->
  Particle = (opts) ->
    @pos = opts.pos
    @vel = opts.vel
    @time = opts.time
    @radius = opts.radius
    @radiusVel = (opts.radiusVel || 0)
    @color = opts.color
    @opacity = (opts.opacity || 1)
    @opacityVel = (opts.opacityVel || 0)
    @isDead = false

  Particle::update = (t) ->
    @time -= t
    @isDead ||= (@time < 0)
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t
    @opacity += @opacityVel * t
    @radius += @radiusVel * t

  Particle::render = (ctx) ->
    ctx.save()
    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @radius, 0, 2*Math.PI)
    ctx.fillStyle = @color
    ctx.globalAlpha *= @opacity
    ctx.fill()
    ctx.restore()

  Particle
