define [], () ->
  Particle = {}

  Particle.init = (pos, vel, time, radius, color) ->
    { pos, vel, time, radius, color, isDead: false }

  Particle.move = (particle, t) ->
    particle.time -= t
    particle.isDead ||= (particle.time < 0)
    particle.pos.x += particle.vel.x * t
    particle.pos.y += particle.vel.y * t

  Particle.draw = (particle, ctx) ->
    ctx.beginPath()
    ctx.arc(particle.pos.x, particle.pos.y, particle.radius, 0, 2*Math.PI)
    ctx.fillStyle = particle.color
    ctx.fill()

  Particle
