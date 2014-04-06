define ["map", "weapon", "bullet", "game"], (Map, Weapon, Bullet, Game) ->
  Tank = (idx, x, y, angle = 0) ->
    @index = idx
    @pos = {x, y}
    @angle = angle
    @vel = {x: 0, y: 0}
    @acc = 0
    @rot = 0
    @firing = false
    @energy = Tank.MAX_ENERGY
    @weapons = [
      new Weapon(Weapon.MachineGun)
      new Weapon(Weapon.Autocannon)
      new Weapon(Weapon.HugeCannon)
    ]
    @activeWeapon = 0


  Tank.RADIUS = 0.45
  Tank.WALL_DISTANCE = 0.01
  Tank.MASS = 100
  Tank.FORCE = 1000
  Tank.FRICTION = 100
  Tank.ANGULAR_SPEED = 1.5*Math.PI
  Tank.FIRING_ANGULAR_SPEED = 0.5*Math.PI
  Tank.BUMP_FACTOR = 0.3
  Tank.BULLET_DIST = 1.2
  Tank.MAX_ENERGY = 100

  Tank::change = ->
    @activeWeapon = (@activeWeapon + 1) % @weapons.length

  Tank::fire = (game) ->
    spec = @weapons[@activeWeapon].spec
    if @energy > spec.energy
      @energy -= spec.energy
      @weapons[@activeWeapon].temperature = spec.cooldown
    else
      return

    angle = @angle + (2*spec.angleVariance * Math.random()) - spec.angleVariance
    posX = @pos.x + Math.sin(angle) * Tank.RADIUS * Tank.BULLET_DIST
    posY = @pos.y + Math.cos(angle) * Tank.RADIUS * Tank.BULLET_DIST
    relVelX = Math.sin(angle) * spec.bullet.speed
    relVelY = Math.cos(angle) * spec.bullet.speed

    game.bullets.push(new Bullet(
      {x: posX, y: posY},
      {x: @vel.x + relVelX, y: @vel.y + relVelY},
      spec.bullet, @index))

    @.impulse(x: -relVelX * spec.bullet.mass, y: -relVelY * spec.bullet.mass)

  Tank::damage = (game, dmg, guilty = undefined) ->
    if @energy > dmg
      @energy -= dmg
    else
      @energy = 0
      Game.tankDestroyed(game, @index, guilty)

  Tank::impulse = (imp) ->
    @vel.x += imp.x / Tank.MASS
    @vel.y += imp.y / Tank.MASS

  Tank::update = (game, t) ->
    for weapon in @weapons
      weapon.temperature -= t if weapon.temperature > 0

    forceX = -@vel.x * Tank.FRICTION + @acc * Math.sin(@angle) * Tank.FORCE
    forceY = -@vel.y * Tank.FRICTION + @acc * Math.cos(@angle) * Tank.FORCE
    @vel.x += forceX * t / Tank.MASS
    @vel.y += forceY * t / Tank.MASS
    @pos.x += @vel.x * t
    @pos.y += @vel.y * t

    if @firing
      @angle += @rot * Tank.FIRING_ANGULAR_SPEED * t
      if @weapons[@activeWeapon].temperature <= 0
        @.fire(game)
    else
      @angle += @rot * Tank.ANGULAR_SPEED * t


  Tank::draw = (ctx) ->
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

  Tank
