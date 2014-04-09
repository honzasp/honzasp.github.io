define [], () ->
  Bonus = (@pos, @vel, @content, @radiusSinVel) ->
    @isDead = false
    @radiusAngle = @radiusSinVel

  Bonus.ENERGY_LOSS = 5
  Bonus.MASS_LOSS = 2
  Bonus.ENERGY_COLOR = "#f0f"
  Bonus.ENERGY_HALF_OPACITY = 50
  Bonus.MASS_COLOR = "#ff0"
  Bonus.MASS_HALF_OPACITY = 20
  Bonus.RADIUS_MID = 0.4
  Bonus.RADIUS_AMP = 0.05
  Bonus.SPEED = 0.3
  Bonus.RADIUS_SIN_VEL = 2*Math.PI * 1.3

  Bonus::update = (t) ->
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t
    @radiusAngle += @radiusSinVel * t
    @radius = Bonus.RADIUS_MID + Math.sin(@radiusAngle) * Bonus.RADIUS_AMP

    if @content.energy?
      @content.energy -= Bonus.ENERGY_LOSS * t
      @isDead ||= @content.energy < 0
    if @content.mass?
      @content.mass -= Bonus.MASS_LOSS * t
      @isDead ||= @content.mass < 0

  Bonus::draw = (ctx) ->
    ctx.save()

    if @content.energy?
      ctx.fillStyle = Bonus.ENERGY_COLOR
      ctx.globalAlpha = Math.pow(0.5, Bonus.ENERGY_HALF_OPACITY/@content.energy)
    else if @content.mass?
      ctx.fillStyle = Bonus.MASS_COLOR
      ctx.globalAlpha = Math.pow(0.5, Bonus.MASS_HALF_OPACITY/@content.mass)
    else
      throw new Error("unknown @content")

    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @radius, 0, 2*Math.PI)
    ctx.fill()
    ctx.restore()

  Bonus
