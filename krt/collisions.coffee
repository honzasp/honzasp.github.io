define ["map", "tank", "bullet", "particle", "weapon"], (Map, Tank, Bullet, Particle, Weapon) ->
  Collisions = {}
  Collisions.tankMap = (tank, map) ->
    pos = {x: tank.pos.x, y: tank.pos.y}
    vel = {x: tank.vel.x, y: tank.vel.y}
    r = Tank.RADIUS

    edgeW = (x, y) ->
      if y < pos.y and pos.y < y + 1 and pos.x < x and pos.x + r > x
        pos.x = x - r - Tank.WALL_DISTANCE
        vel.x *= -Tank.BUMP_FACTOR
    edgeE = (x, y) ->
      if y < pos.y and pos.y < y + 1 and pos.x > x and pos.x - r < x
        pos.x = x + r + Tank.WALL_DISTANCE
        vel.x *= -Tank.BUMP_FACTOR
    edgeN = (x, y) ->
      if x < pos.x and pos.x < x + 1 and pos.y < y and pos.y + r > y
        pos.y = y - r - Tank.WALL_DISTANCE
        vel.y *= -Tank.BUMP_FACTOR
    edgeS = (x, y) ->
      if x < pos.x and pos.x < x + 1 and pos.y > y and pos.y - r < y
        pos.y = y + r + Tank.WALL_DISTANCE
        vel.y *= -Tank.BUMP_FACTOR

    corner = (x, y, isNorth, isWest) ->
      d = {x: x - pos.x, y: y - pos.y}
      if d.x * d.x + d.y * d.y < r*r
        vel.x *= -Tank.BUMP_FACTOR
        vel.y *= -Tank.BUMP_FACTOR

        if isNorth 
          if isWest
            pos.x += d.x - Math.sqrt(r*r - d.y*d.y)
            pos.y += d.y - Math.sqrt(r*r - d.x*d.x)
          else
            pos.x += d.x + Math.sqrt(r*r - d.y*d.y)
            pos.y += d.y - Math.sqrt(r*r - d.x*d.x)
        else
          if isWest
            pos.x += d.x - Math.sqrt(r*r - d.y*d.y)
            pos.y += d.y + Math.sqrt(r*r - d.x*d.x)
          else
            pos.x += d.x + Math.sqrt(r*r - d.y*d.y)
            pos.y += d.y + Math.sqrt(r*r - d.x*d.x)

    isFull = (x, y) ->
      !Map.contains(map, x, y) or Map.get(map, x, y) != Map.EMPTY

    for x in [Math.floor(pos.x - r) .. Math.floor(pos.x + r)]
      for y in [Math.floor(pos.y - r) .. Math.floor(pos.y + r)]
        if isFull(x, y)
          edgeW(x, y)
          edgeE(x+1, y)
          edgeN(x, y)
          edgeS(x, y+1)
          corner(x, y, true, true)
          corner(x+1, y, true, false)
          corner(x, y+1, false, true)
          corner(x+1, y+1, false, false)

    tank.pos = pos
    tank.vel = vel

  Collisions.tankTank = (tank1, tank2) ->
    d = {x: tank1.pos.x - tank2.pos.x, y: tank1.pos.y - tank2.pos.y}
    l = Math.sqrt(d.x*d.x + d.y*d.y)
    r = Tank.RADIUS

    if l < 2*r
      u = {x: d.x / l, y: d.y / l}
      tank1.pos =
        x: tank1.pos.x + u.x * (r-l/2)
        y: tank1.pos.y + u.y * (r-l/2)
      tank2.pos =
        x: tank2.pos.x - u.x * (r-l/2)
        y: tank2.pos.y - u.y * (r-l/2)

      vel1 = tank1.vel
      vel2 = tank2.vel
      velP1 = vel1.x * u.y - vel1.y * u.x
      velP2 = vel2.x * u.y - vel2.y * u.x

      tank1.vel = 
        x: velP1*u.y + vel2.x - velP2*u.y
        y: velP1*(-u.x) + vel2.y - velP1*(-u.x)

      tank2.vel =
        x: velP2*u.y + vel1.x - velP1*u.y
        y: velP2*(-u.x) + vel1.y - velP1*(-u.x)

  lineMap = (start, end, map) ->
    wallHit = null

    hit = (x, y, mapX, mapY, d) ->
      return unless d >= 0
      unless mapX >= 0 and mapX < map.width and mapY >= 0 and mapY < map.height
        wallHit = {d:Infinity, pos: {x,y}}
      else
        return if Map.get(map, mapX, mapY) == Map.EMPTY
        if !wallHit or d < wallHit.d
          wallHit = {d, pos: {x,y}, map: {x:mapX, y:mapY}}

    hit(start.x, start.y, Math.floor(start.x), Math.floor(start.y), 0)

    northEdges = ->
      y = Math.ceil(start.y)
      while y < Math.ceil(end.y)
        d = (y - start.y) / (end.y - start.y)
        x = start.x + (end.x - start.x) * d
        hit(x, y, Math.floor(x), y, d)
        y = y + 1
      undefined

    southEdges = ->
      y = Math.floor(start.y) - 1
      while y > Math.floor(end.y)
        d = (start.y - y - 1) / (start.y - end.y)
        x = start.x + (end.x - start.x) * d
        hit(x, y+1, Math.floor(x), y, d)
        y = y - 1
      undefined

    westEdges = ->
      x = Math.ceil(start.x)
      while x < Math.ceil(end.x)
        d = (x - start.x) / (end.x - start.x)
        y = start.y + (end.y - start.y) * d
        hit(x+1, y, x, Math.floor(y), d)
        x = x + 1
      undefined

    eastEdges = ->
      x = Math.floor(start.x) - 1
      while x > Math.floor(end.x)
        d = (start.x - x - 1) / (start.x - end.x)
        y = start.y + (end.y - start.y) * d
        hit(x, y, x, Math.floor(y), d)
        x = x - 1
      undefined

    if false
      northEdges = ->
        y = Math.ceil(start.y)
        while y <= Math.floor(end.y)
          d = (y - start.y) / (end.y - start.y)
          x = d*(end.x - start.x) + start.x
          hit(x, y, Math.floor(x), y, d)
          y = y + 1
        undefined
      southEdges = ->
        undefined
      westEdges = ->
        undefined
      eastEdges = ->
        undefined

    northEdges()
    southEdges()
    westEdges()
    eastEdges()

    wallHit

  lineTank = (start, end, tank) ->
    [s, e, p, r] = [start, end, tank.pos, Tank.RADIUS]
    ds = solveQuad \
      (e.x-s.x)*(e.x-s.x) + (e.y-s.y)*(e.y-s.y),
      2*(e.x-s.x)*(s.x-p.x) + 2*(e.y-s.y)*(s.y-p.y),
      (s.x-p.x)*(s.x-p.x) + (s.y-p.y)*(s.y-p.y) - r*r
    ds = (d for d in ds when d >= 0 and d <= 1)

    d = if ds.length == 2
        Math.min(ds[0], ds[1])
      else if ds.length == 1
        ds[0]

    {d, pos: {x: s.x + d*(e.x-s.x), y: s.y + d*(e.y-s.y)}, tank} if d?

  solveQuad = (a, b, c) ->
    disc = b*b - 4*a*c
    if disc > 0
      discSqrt = Math.sqrt(disc)
      [(-b - discSqrt)/(2*a), (-b + discSqrt)/(2*a)]
    else if disc == 0
      [-b / (2*a)]
    else
      []

  Collisions.bullet = (bullet, game, t) ->
    {tanks, map} = game
    start = {x: bullet.pos.x, y: bullet.pos.y}
    end = {x: bullet.pos.x + bullet.vel.x*t, y: bullet.pos.y + bullet.vel.y*t}
    end.x = end.x + 0.001 if Math.abs(end.x - start.x) < 0.001
    end.y = end.y + 0.001 if Math.abs(end.y - start.y) < 0.001

    nearestHit = lineMap(start, end, map)

    for i in [0...tanks.length]
      if tankHit = lineTank(start, end, tanks[i])
        if !nearestHit or tankHit.d < nearestHit.d
          nearestHit = tankHit

    if nearestHit
      bullet.isDead = true
      spec = bullet.spec

      if (m = nearestHit.map)?
        toughness = Map.squares[Map.get(map, m.x, m.y)].toughness
        if Math.pow(toughness, spec.damage) < Math.random()
          Map.set(map, m.x, m.y, Map.EMPTY)
      if (tank = nearestHit.tank)?
        tank.impulse(x: bullet.vel.x * spec.mass, y: bullet.vel.y * spec.mass)
        tank.damage(game, spec.damage, bullet.owner)

      if (fragment = spec.fragment)?
        fragmentCount = Math.floor(spec.mass / fragment.mass)
        for i in [0...fragmentCount]
          angle = 2*Math.PI * Math.random()
          posX = Math.sin(angle) * Weapon.FRAGMENT_RADIUS + nearestHit.pos.x
          posY = Math.cos(angle) * Weapon.FRAGMENT_RADIUS + nearestHit.pos.y
          velX = Math.sin(angle) * fragment.speed + bullet.vel.x
          velY = Math.cos(angle) * fragment.speed + bullet.vel.y
          bullet = new Bullet(
            {x: nearestHit.pos.x, y: nearestHit.pos.y},
            {x: velX, y: velY},
            fragment, bullet.owner)
          game.bullets.push(bullet)

      spec.boom(game, nearestHit.pos)

    undefined

  Collisions
