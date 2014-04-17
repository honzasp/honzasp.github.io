define [], () ->
  Bonus = (@pos, @vel, @content, @radiusSinVel) ->
    @isDead = false
    @radiusAngle = @radiusSinVel

  Bonus.ENERGY_LOSS = 5
  Bonus.MASS_LOSS = 2
  Bonus.ENERGY_COLORS = ["#2b9ad9", "#2b8ad9", "#2b78d9", "#2b60d9", "#2b4fd9"]
  Bonus.ENERGY_HALF_OPACITY = 50
  Bonus.MASS_COLORS = ["#ddb94f", "#ddae4f", "#ddc94f", "#ddd14f"]
  Bonus.MASS_HALF_OPACITY = 20
  Bonus.RADIUS_MID = 0.4
  Bonus.RADIUS_AMP = 0.05
  Bonus.SPEED = 0.3
  Bonus.RADIUS_SIN_VEL = 2*Math.PI * 1.3
  Bonus.SOUND_GAIN = 0.6

  Bonus::update = (t) ->
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t
    @radiusAngle += @radiusSinVel * t
    @radius = Bonus.RADIUS_MID + Math.sin(@radiusAngle) * Bonus.RADIUS_AMP
    @content.update(t)
    @isDead ||= @content.isEmpty()

  Bonus::render = (ctx) ->
    ctx.save()

    ctx.fillStyle = @content.color
    ctx.globalAlpha *= @content.getOpacity()

    ctx.beginPath()
    ctx.arc(@pos.x, @pos.y, @radius, 0, 2*Math.PI)
    ctx.fill()
    ctx.restore()

  Bonus.Energy = (@energy) ->
    @color = Bonus.ENERGY_COLORS[Math.floor(Bonus.ENERGY_COLORS.length * Math.random())]
    @getSound = "get_energy"
  Bonus.Energy::update = (t) ->
    @energy -= Bonus.ENERGY_LOSS * t
  Bonus.Energy::isEmpty = ->
    @energy <= 0
  Bonus.Energy::getOpacity = ->
    Math.pow(0.5, Bonus.ENERGY_HALF_OPACITY/@energy)

  Bonus.Mass = (@mass) ->
    @color = Bonus.MASS_COLORS[Math.floor(Bonus.MASS_COLORS.length * Math.random())]
    @getSound = "get_mass"
  Bonus.Mass::update = (t) ->
    @mass -= Bonus.MASS_LOSS * t
  Bonus.Mass::isEmpty = ->
    @mass <= 0
  Bonus.Mass::getOpacity = ->
    Math.pow(0.5, Bonus.MASS_HALF_OPACITY/@mass)



  Bonus
