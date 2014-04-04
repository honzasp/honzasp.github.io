define [], () ->
  class Bullet
    @RADIUS = 0.1
    @DESTROY_PROB = 0.2
    @MASS = 2

    constructor: (@game, @pos, @vel, @time) ->

    update: (t) ->
      @time = @time - t
      if @time < 0
        @isDead = true
        return
      @pos.x = @pos.x + @vel.x * t
      @pos.y = @pos.y + @vel.y * t

    draw: (ctx) ->
      ctx.beginPath()
      ctx.arc(@pos.x, @pos.y, Bullet.RADIUS, 0, 2*Math.PI)
      ctx.fillStyle = "#f00"
      ctx.fill()
