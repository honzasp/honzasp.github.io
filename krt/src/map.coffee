define ["perlin"], (Perlin) ->
  Map = {}
  Map.init = (width, height) ->
    if Uint8Array?
      ary = new Uint8Array(width * height)
    else
      ary = new Array(width * height)
      for i in [0...width * height]
        ary[i] = Map.EMPTY
    { ary, width, height, bases: [] }

  Map.squares = new Array(256)
  Map.squares[Map.EMPTY = 0] =
    {color: "#333333"}
  Map.squares[Map.ROCK_1 = 10] =
    {color: "#a39c89", toughness: 0.4, energy: 80, prob: 0.5}
  Map.squares[Map.ROCK_2 = 11] =
    {color: "#a79f8c", toughness: 0.5, mass: 30, prob: 0.4}
  Map.squares[Map.ROCK_3 = 12] =
    {color: "#aaa18b", toughness: 0.6, energy: 90, prob: 0.4}
  Map.squares[Map.ROCK_4 = 13] =
    {color: "#aea287", toughness: 0.5, energy: 60, prob: 0.3}
  Map.squares[Map.ROCK_5 = 14] =
    {color: "#a79b7e", toughness: 0.5, energy: 100, prob: 0.3}
  Map.squares[Map.ROCK_6 = 15] =
    {color: "#a69b83", toughness: 0.4, mass: 10, prob: 0.6}
  Map.squares[Map.CONCRETE = 20] =
    {color: "#a3a3a3", toughness: 0.998}
  Map.squares[Map.STEEL = 30] =
    {color: "#6f7989", toughness: 0.995}
  Map.squares[Map.TITANIUM = 31] =
    {color: "#6287b2", toughness: 0.999}
  Map.squares[Map.GOLD = 32] =
    {color: "#dfbe23", toughness: 0.3, energy: 300}
  Map.squares[Map.LEAD = 33] =
    {color: "#5b7380", toughness: 0.35, mass: 50}
  Map.squares[Map.VOID = 255] =
    {color: "#000000"}

  Map.get = (map, x, y) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y]

  Map.set = (map, x, y, val) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y] = val

  Map.setOrNothing = (map, x, y, val) ->
    map.ary[x * map.height + y] = val if Map.contains(map, x, y)

  Map.contains = (map, x, y) ->
    throw new Error("only integer coordinates allowed") unless x == Math.floor(x) and y == Math.floor(y)
    x >= 0 and x < map.width and y >= 0 and y < map.height

  Map.BASE_SIZE = 8
  Map.BASE_DOOR_SIZE = 2
  Map.NODE_DENSITY = 1 / 3000
  Map.ROCK_RATIO = 0.997
  Map.DEPOSIT_COUNT = 10
  Map.DEPOSIT_RADIUS = 4
  Map.CHAMBER_SIZE = 8
  Map.BUNKER_SIZE = 6
  Map.OCTAVES = 4

  Map.gen = (settings) ->
    width = settings.mapWidth
    height = settings.mapHeight
    baseCount = settings.playerDefs.length
    nodeCount = Math.floor(width * height * Map.NODE_DENSITY)

    rng = new Map.Rng(settings.mapSeed)
    map = Map.init(width, height)
    Map.gen.fillRock(map, rng, settings)

    web = Map.gen.pointWeb(rng, baseCount + nodeCount, width - 1, height - 1)

    for node in web[baseCount..]
      Map.gen.node(map, rng, node)

    map.bases = bases = for {x, y} in web[0...baseCount]
      x: Math.floor(Math.min(width - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, x)))
      y: Math.floor(Math.min(height - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, y)))
    for base in bases
      Map.gen.base(map, rng, base)

    map

  Map.gen.fillRock = (map, rng, settings) ->
    perlin = Perlin.gen(rng.genInt24(), map.width, map.height, 
      octaves: Map.OCTAVES, amp: settings.mapAmp)
    for y in [0...map.height] by 1
      for x in [0...map.width] by 1
        if perlin[y*map.width + x] > settings.mapCaveLimit
          Map.set(map, x, y, Map.gen.rockSquare(rng))
    undefined

  Map.gen.rockSquare = (rng) ->
    r = rng.gen()
    if r < Map.ROCK_RATIO
      switch Math.floor(r / Map.ROCK_RATIO * 6)
        when 0 then Map.ROCK_1
        when 1 then Map.ROCK_2
        when 2 then Map.ROCK_3
        when 3 then Map.ROCK_4
        when 4 then Map.ROCK_5
        when 5 then Map.ROCK_6
    else
      Map.gen.preciousSquare(rng,)

  Map.gen.preciousSquare = (rng) ->
    switch rng.genInt(4)
      when 0 then Map.STEEL
      when 1 then Map.TITANIUM
      when 2 then Map.GOLD
      when 3 then Map.LEAD

  Map.gen.base = (map, rng, base) ->
    {x, y} = base
    s = Map.BASE_SIZE

    for i in [0...s]
      Map.set(map, x+i, y, Map.TITANIUM)
      Map.set(map, x+i, y+s-1, Map.TITANIUM)
      Map.set(map, x, y+i, Map.TITANIUM)
      Map.set(map, x+s-1, y+i, Map.TITANIUM)

    for i in [1...s-1]
      for j in [1...s-1]
        Map.set(map, x+i, y+j, Map.EMPTY)

    for i in [0...Map.BASE_DOOR_SIZE]
      dx = x + Math.floor(s / 2 - Map.BASE_DOOR_SIZE / 2) + i
      Map.set(map, dx, y, Map.EMPTY)
      Map.set(map, dx, y+s-1, Map.EMPTY)

    undefined

  Map.gen.node = (map, rng, pos) ->
    switch rng.genInt(3)
      when 0 then Map.gen.deposit(map, rng, pos)
      when 1 then Map.gen.chamber(map, rng, pos)
      when 2 then Map.gen.bunker(map, rng, pos)

  Map.gen.deposit = (map, rng, pos) ->
    count = Math.ceil(Map.DEPOSIT_COUNT * (rng.gen() + 0.5))
    for i in [0...count]
      angle = rng.gen() * 2*Math.PI
      dist = Math.ceil(Map.DEPOSIT_RADIUS * (rng.gen() + 0.5))
      x = Math.floor(Math.sin(angle) * dist + pos.x)
      y = Math.floor(Math.cos(angle) * dist + pos.y)
      if Map.contains(map, x, y) and Map.get(map, x, y) != Map.EMPTY
        Map.set(map, x, y, Map.gen.preciousSquare(rng))
    undefined

  Map.gen.chamber = (map, rng, pos) ->
    w = Math.ceil(Map.CHAMBER_SIZE * (rng.gen() + 0.5))
    h = Math.ceil(Map.CHAMBER_SIZE * (rng.gen() + 0.5))
    for x in [pos.x ... pos.x + w] by 1
      for y in [pos.y ... pos.y + h] by 1
        Map.set(map, x, y, Map.EMPTY) if Map.contains(map, x, y)
    undefined

  Map.gen.bunker = (map, rng, pos) ->
    w = Math.ceil(Map.BUNKER_SIZE * (rng.gen() + 0.5))
    h = Math.ceil(Map.BUNKER_SIZE * (rng.gen() + 0.5))

    wall = switch Math.floor(rng.gen() * 2)
      when 0 then Map.CONCRETE
      else        Map.STEEL

    for x in [pos.x ... pos.x + w] by 1
      Map.setOrNothing(map, x, pos.y, wall) 
      Map.setOrNothing(map, x, pos.y + h - 1, wall) 

    for y in [pos.y ... pos.y + h] by 1
      Map.setOrNothing(map, pos.x, y, wall)
      Map.setOrNothing(map, pos.x + w - 1, y, wall)

    for x in [pos.x + 1 ... pos.x + w - 1] by 1
      for y in [pos.y + 1 ... pos.y + h - 1] by 1
        Map.setOrNothing(map, x, y, Map.EMPTY)

    doorPos =
      if rng.gen() < 0.5
        doorX = pos.x + Math.floor(rng.gen() * (w - 2)) + 1
        doorY = if rng.gen() < 0.5 then pos.y else pos.y + h - 1
        [{x: doorX, y: doorY}, {x: doorX + 1, y: doorY}]
      else
        doorX = if rng.gen() < 0.5 then pos.x else pos.x + w - 1
        doorY = pos.x + Math.floor(rng.gen() * (h - 2)) + 1
        [{x: doorX, y: doorY}, {x: doorX, y: doorY + 1}]

    for {x, y} in doorPos
      Map.setOrNothing(map, x, y, Map.EMPTY)

    undefined

  Map.gen.pointWeb = (rng, count, width, height) ->
    points = for i in [0...count] by 1
      {x: rng.gen()*width, y: rng.gen()*height}

    clampX = (x) -> Math.max(0, Math.min(width, x))
    clampY = (y) -> Math.max(0, Math.min(height, y))

    for t in [0...10] by 1
      for i in [0...count] by 1
        dx = points[i].x - width / 2
        dy = points[i].y - height / 2
        points[i].x -= dx * 0.02 + 5*(rng.gen() - 0.5)
        points[i].y -= dy * 0.02 + 5*(rng.gen() - 0.5)

      for i in [0...count] by 1
        for j in [i+1...count] by 1
          d = Map.dist(points[i], points[j])
          ux = dx / d
          uy = dy / d
          f = 20 / d
          points[i].x = clampX(points[i].x + ux * f)
          points[i].y = clampY(points[i].y + uy * f)
          points[j].x = clampX(points[j].x - ux * f)
          points[j].y = clampY(points[j].y - uy * f)

      undefined

    for {x, y} in points
      x: Math.floor(x), y: Math.floor(y)

  Map.dist = (p1, p2) ->
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    Math.sqrt(dx*dx + dy*dy)

  Map.Rng = (strSeed) ->
    [a, b, c] = [0xbeef, 0xdead, 0xb00]
    for i in [0...strSeed.length] by 1
      ch = strSeed.charCodeAt(i)
      a = c ^ (a << 13) ^ (b << 3) ^ ch
      b = a ^ (b << 15) ^ (c << 2) ^ (ch >> 1)
      c = b ^ (c << 5) ^ (a << 13) ^ ch
    @a = a; @b = b; @c = c

  Map.Rng::genInt24 = ->
    @a = @a ^ (((@b << 13) + (@c * 6823))|0)
    @b = @b ^ (((@c << 11) + (@a * 7727))|0)
    @c = @c ^ (((@a << 10) + (@b * 7549))|0)
    x = ((@a ^ 5297)+(@b ^ 4447))|0
    ((x * ((x * x)|0 * 3209 + 3541))&0xffffff)

  Map.Rng::gen = ->
    @.genInt24() / 0xffffff

  Map.Rng::genRange = (from, to) ->
    from + @.gen() * (to - from)

  Map.Rng::genInt = (limit) ->
    Math.floor(@.gen() * limit)

  Map.Rng::genIntRange = (from, to) ->
    @.genInt(to - from) + from

  Map
