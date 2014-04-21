"use strict"
define ["map", "weapon", "bullet", "game", "audio"], \
        (Map,   Weapon,   Bullet,   Game,   Audio) ->
  Tank = (idx, x, y, angle, color, hum) ->
    @index = idx
    @pos = {x, y}
    @angle = angle
    @momentum = {x: 0, y: 0}
    @angMomentum = 0
    @acc = 0
    @rot = 0
    @firing = false
    @exploding = undefined
    @destroyedBy = undefined
    @isDead = false
    @weapons = [
      new Weapon(Weapon.MachineGun)
      new Weapon(Weapon.MiningGun)
      new Weapon(Weapon.EmergencyGun)
      new Weapon(Weapon.Autocannon)
      new Weapon(Weapon.HugeCannon)
    ]
    @activeWeapon = 0
    @color = color
    @hum = hum
    @.setEnergy(Tank.START_ENERGY)
    @.setMass(Tank.START_MASS)
    @

  Tank.WALL_DISTANCE = 0.01
  Tank.FORCE = 1500
  Tank.FRICTION = 100
  Tank.TORQUE = 700
  Tank.FIRING_TORQUE = 300
  Tank.ANGULAR_FRICTION = 150
  Tank.BUMP_FACTOR = 0.5
  Tank.BULLET_DIST = 1.2
  Tank.START_ENERGY = 1000
  Tank.START_MASS = 100
  Tank.DENSITY = 120
  Tank.MIN_FIRE_ENERGY = 10
  Tank.VISION_ENERGY = 400
  Tank.MIN_MASS = 50
  Tank.EXPLODING_TIME = 3

  Tank.ENERGY_DRAIN = (tank) ->
    if tank.acc != 0 or tank.rot != 0
      7 + tank.energy * 0.002
    else
      1 + tank.energy * 0.002
  Tank.HUM_GAIN = (speed) -> 0.4*(1.1 - Math.pow(0.9, speed/5))
  Tank.HUM_PLAYBACK = (speed) -> 0.5 + Math.pow(1.1, speed/10)
  Tank.HIT_SOUND_GAIN = (impulse) -> 0.8*(1 - Math.pow(0.97, impulse/12))
  Tank.DAMAGE_SOUND_GAIN = (dmg) -> 0.9*(1 - Math.pow(0.65, dmg/20))

  Tank::change = ->
    @activeWeapon = (@activeWeapon + 1) % @weapons.length

  Tank::fire = (game) ->
    {spec} = weapon = @weapons[@activeWeapon]
    return unless weapon.temperature <= 0
    return unless @mass - spec.bullet.mass >= Tank.MIN_MASS
    return unless @energy - spec.energy >= Tank.MIN_FIRE_ENERGY

    angle = @angle + (2*spec.angleVariance * Math.random()) - spec.angleVariance
    posX = @pos.x + Math.sin(angle) * @radius * Tank.BULLET_DIST
    posY = @pos.y + Math.cos(angle) * @radius * Tank.BULLET_DIST
    relVelX = Math.sin(angle) * spec.bullet.speed
    relVelY = Math.cos(angle) * spec.bullet.speed

    game.bullets.push(new Bullet(
      {x: posX, y: posY},
      {x: @momentum.x/@mass + relVelX, y: @momentum.y/@mass + relVelY},
      spec.bullet, @index))

    weapon.temperature = spec.cooldown
    @.setMass(@mass - spec.bullet.mass, game)
    @.setEnergy(@energy - spec.energy, game)
    @.impulse(x: -relVelX * spec.bullet.mass, y: -relVelY * spec.bullet.mass)
    Audio.sound(game, spec.sound, Weapon.FIRE_SOUND_GAIN)

  Tank::hurt = (game, dmg, guilty = undefined) ->
    @.setEnergy(@energy - dmg, game, guilty)

  Tank::receive = (game, content) ->
    if content.energy?
      @.setEnergy(@energy + content.energy, game)
    if content.mass?
      @.setMass(@mass + content.mass, game)

  Tank::setEnergy = (energy, game, guilty = undefined) ->
    if energy < 0
      @energy = 0
      @.destroy(game, guilty)
    else
      @energy = energy

  Tank::setMass = (mass, game, guilty = undefined) ->
    @mass = mass
    @radius = Math.sqrt(@mass / Tank.DENSITY / Math.PI)
    if mass < Tank.MIN_MASS
      @.destroy(game, guilty)

  Tank::destroy = (game, guilty) ->
    unless @exploding?
      Game.tankDestroyed(game, @index, guilty)
      boom =
        count: 50, speed: 40, time: 1.5
        radius: 1.2, color: @color, opacity: 0.6
        sound: "boom_tank"
      Game.boom(game, @pos, boom)
      @exploding = Tank.EXPLODING_TIME

  Tank::impulse = (imp) ->
    @momentum.x += imp.x
    @momentum.y += imp.y

  Tank::update = (game, t) ->
    for weapon in @weapons
      weapon.temperature -= t if weapon.temperature > 0

    if @exploding?
      @exploding -= t
      @isDead ||= (@exploding < 0)
      @acc = 0
      @rot = 0

    velX = @momentum.x / @mass
    velY = @momentum.y / @mass
    @pos.x += velX * t
    @pos.y += velY * t
    @momentum.x += (-velX * Tank.FRICTION + @acc * Math.sin(@angle) * Tank.FORCE) * t
    @momentum.y += (-velY * Tank.FRICTION + @acc * Math.cos(@angle) * Tank.FORCE) * t

    if @firing
      @.fire(game)

    momentOfInertia = 0.5 * @mass * @radius * @radius
    angVel = @angMomentum / momentOfInertia
    torque = @rot * (if @firing then Tank.FIRING_TORQUE else Tank.TORQUE) - angVel*Tank.ANGULAR_FRICTION
    @angMomentum += torque * t
    @angle += angVel * t

    if @hum?
      time = Audio.currentTime(game)
      speed = Math.sqrt(velX*velX + velY*velY)
      @hum.gainNode.gain.value = Tank.HUM_GAIN(speed)
      @hum.sourceNode.playbackRate.value = Tank.HUM_PLAYBACK(speed)

    @.setEnergy(@energy - Tank.ENERGY_DRAIN(@) * t, game)

  Tank::render = (ctx) ->
    ctx.save()
    ctx.translate(@pos.x, @pos.y)
    ctx.rotate(-@angle)
    ctx.scale(@radius, @radius)

    ctx.beginPath()
    ctx.arc(0, 0, 1.0, 0, Math.PI*2)
    if @exploding?
      ctx.globalAlpha *= 0.2
    ctx.fillStyle = @color
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
