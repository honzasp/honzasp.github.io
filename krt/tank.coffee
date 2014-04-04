define ["map", "bullet"], (Map, Bullet) ->
  class Tank
    @RADIUS = 0.45
    @WALL_DISTANCE = 0.01
    @MASS = 100
    @FORCE = 1000
    @FRICTION = 100
    @ANGULAR_SPEED = 1.5*Math.PI
    @BUMP_FACTOR = 0.3
    @BULLET_SPEED = 100
    @BULLET_TIME = 2
    @BULLET_DIST = 1.1

    constructor: (@game, @pos, @angle = 0) ->
      @vel = { x: 0, y: 0 }
      @acc = 0
      @rot = 0

    fire: ->
      pos =
        x: @pos.x + Math.sin(@angle) * Tank.RADIUS * Tank.BULLET_DIST
        y: @pos.y + Math.cos(@angle) * Tank.RADIUS * Tank.BULLET_DIST
      relVel =
        x: Math.sin(@angle) * Tank.BULLET_SPEED
        y: Math.cos(@angle) * Tank.BULLET_SPEED
      vel = {x: relVel.x + @vel.x, y: relVel.y + @vel.y}
      @game.bullets.push(new Bullet(@game, pos, vel, Tank.BULLET_TIME))
      #@impulse(x: -relVel.x * Bullet.MASS, y: -relVel.y * Bullet.MASS)

    impulse: (imp) ->
      @vel = {x: @vel.x + imp.x / Tank.MASS, y: @vel.y + imp.y / Tank.MASS}

    update: (t) ->
      force =
        x: -@vel.x * Tank.FRICTION + @acc * Math.sin(@angle) * Tank.FORCE
        y: -@vel.y * Tank.FRICTION + @acc * Math.cos(@angle) * Tank.FORCE
      @vel =
        x: @vel.x + force.x * t / Tank.MASS
        y: @vel.y + force.y * t / Tank.MASS
      @pos =
        x: @pos.x + @vel.x * t
        y: @pos.y + @vel.y * t
      @angle = @angle + @rot * Tank.ANGULAR_SPEED * t


    draw: (ctx) ->
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


