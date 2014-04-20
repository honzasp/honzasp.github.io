define ["exports", "map", "tank", "bullet", "particle", "weapon", "bonus", "update"], \
(exports, Map, Tank, Bullet, Particle, Weapon, Bonus, Update) ->
  Collisions = exports
  Collisions.tankMap = (game, tank) ->
    pos = {x: tank.pos.x, y: tank.pos.y}
    vel = {x: tank.vel.x, y: tank.vel.y}
    r = tank.radius
    map = game.map
    imp = 0

    edgeW = (x, y) ->
      if y < pos.y and pos.y < y + 1 and pos.x < x and pos.x + r > x
        pos.x = x - r - Tank.WALL_DISTANCE
        vel.x *= -Tank.BUMP_FACTOR
        imp += Math.abs(vel.x) * (1 + Tank.BUMP_FACTOR) * tank.mass
    edgeE = (x, y) ->
      if y < pos.y and pos.y < y + 1 and pos.x > x and pos.x - r < x
        pos.x = x + r + Tank.WALL_DISTANCE
        vel.x *= -Tank.BUMP_FACTOR
        imp += Math.abs(vel.x) * (1 + Tank.BUMP_FACTOR) * tank.mass
    edgeN = (x, y) ->
      if x < pos.x and pos.x < x + 1 and pos.y < y and pos.y + r > y
        pos.y = y - r - Tank.WALL_DISTANCE
        vel.y *= -Tank.BUMP_FACTOR
        imp += Math.abs(vel.y) * (1 + Tank.BUMP_FACTOR) * tank.mass
    edgeS = (x, y) ->
      if x < pos.x and pos.x < x + 1 and pos.y > y and pos.y - r < y
        pos.y = y + r + Tank.WALL_DISTANCE
        vel.y *= -Tank.BUMP_FACTOR
        imp += Math.abs(vel.y) * (1 + Tank.BUMP_FACTOR) * tank.mass

    corner = (x, y, isNorth, isWest) ->
      d = {x: x - pos.x, y: y - pos.y}
      if d.x * d.x + d.y * d.y < r*r
        vel.x *= -Tank.BUMP_FACTOR
        vel.y *= -Tank.BUMP_FACTOR
        imp += (Math.abs(vel.x) + Math.abs(vel.y)) * (1 + Tank.BUMP_FACTOR) * tank.mass

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
    if imp != 0
      Update.tankMapHit(game, tank, imp)

  Collisions.tankTank = (game, tank1, tank2) ->
    d = {x: tank1.pos.x - tank2.pos.x, y: tank1.pos.y - tank2.pos.y}
    l = Math.sqrt(d.x*d.x + d.y*d.y)
    r1 = tank1.radius
    r2 = tank2.radius

    if l < r1+r2
      u = {x: d.x / l, y: d.y / l}
      tank1.pos =
        x: tank1.pos.x + u.x * (r1-l/2)
        y: tank1.pos.y + u.y * (r1-l/2)
      tank2.pos =
        x: tank2.pos.x - u.x * (r2-l/2)
        y: tank2.pos.y - u.y * (r2-l/2)

      mom1 = {x: tank1.vel.x * tank1.mass, y: tank1.vel.y * tank1.mass}
      mom2 = {x: tank2.vel.x * tank2.mass, y: tank2.vel.y * tank2.mass}
      momD1 = mom1.x * u.x + mom1.y * u.y
      momD2 = mom2.x * u.x + mom2.y * u.y

      tank1.vel =
        x: (mom1.x + u.x*(momD2 - momD1)) / tank1.mass
        y: (mom1.y + u.y*(momD2 - momD1)) / tank1.mass
      tank2.vel =
        x: (mom2.x + u.x*(momD1 - momD2)) / tank2.mass
        y: (mom2.y + u.y*(momD1 - momD2)) / tank2.mass

      Update.tankTankHit(game, tank1, tank2, Math.abs(momD1) + Math.abs(momD2))

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

    northEdges()
    southEdges()
    westEdges()
    eastEdges()

    wallHit

  lineTank = (start, end, tank) ->
    s = start; e = end; p = tank.pos; r = tank.radius
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

  Collisions.bullet = (game, bullet, t) ->
    {tanks, map} = game
    start = {x: bullet.pos.x, y: bullet.pos.y}
    end = {x: bullet.pos.x + bullet.vel.x*t, y: bullet.pos.y + bullet.vel.y*t}
    end.x = end.x + 0.001 if Math.abs(end.x - start.x) < 0.001
    end.y = end.y + 0.001 if Math.abs(end.y - start.y) < 0.001

    nearestHit = lineMap(start, end, map)

    for tank in tanks
      if tankHit = lineTank(start, end, tank)
        if !nearestHit? or tankHit.d < nearestHit.d
          nearestHit = tankHit

    if nearestHit?
      Update.bulletHit(game, bullet, nearestHit)

    undefined

  Collisions.bonus = (game, bonus) ->
    for tank in game.tanks
      dx = tank.pos.x - bonus.pos.x
      dy = tank.pos.y - bonus.pos.y
      l = Math.sqrt(dx*dx + dy*dy)
      if l < bonus.radius + tank.radius
        Update.bonusHit(game, bonus, tank)
        break
    undefined

  Collisions
