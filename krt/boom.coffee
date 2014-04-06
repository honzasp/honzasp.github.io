define ["particle"], (Particle) ->
  Boom = {}

  Boom.PARTICLE_OPACITY = 0.6

  Boom.boom = ({count: COUNT, speed: SPEED, time: TIME, radius: RADIUS, color: COLOR}) ->
    (game, pos) ->
      for i in [0...COUNT]
        angle = 2*Math.PI * Math.random()
        speed = 0.5*SPEED + Math.random()*SPEED
        time = 0.5*TIME + Math.random()*TIME
        radius = 0.5*RADIUS + Math.random()*RADIUS
        velX = Math.sin(angle) * speed
        velY = Math.cos(angle) * speed
        game.particles.push(new Boom.Particle(
          {x: pos.x, y: pos.y},
          {x: velX, y: velY},
          time, radius, COLOR
        ))
      undefined

  Boom.Particle = (args...) ->
    Particle.call(@, args...)
    @opacity = Boom.PARTICLE_OPACITY
    @opacityVel = @opacity / @time

  Boom.Particle::move = (t) ->
    Particle::move.call(@, t)
    @opacity -= @opacityVel * t

  Boom.Particle::draw = (ctx) ->
    ctx.save()
    ctx.globalAlpha = @opacity
    Particle::draw.call(@, ctx)
    ctx.restore()

  Boom
