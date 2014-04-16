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
  Map.NODE_DENSITY = 1 / 8000
  Map.ROCK_RATIO = 0.997
  Map.DEPOSIT_COUNT = 10
  Map.DEPOSIT_RADIUS = 4
  Map.CHAMBER_SIZE = 8
  Map.BUNKER_SIZE = 6
  Map.FILL_OCTAVES = 4
  Map.TYPE_OCTAVES = 4
  Map.TYPE_AMP = 0.7
  Map.TYPE_SCALE = 8

  Map.gen = (settings) ->
    width = settings.mapWidth
    height = settings.mapHeight
    baseCount = settings.playerDefs.length
    nodeCount = Math.floor(width * height * Map.NODE_DENSITY)

    rng = new Map.Rng(settings.mapSeed)
    map = Map.init(width, height)
    Map.gen.fillRock(map, rng, settings)

    for {x, y} in Map.gen.pointWeb(rng, nodeCount, width - 1, height - 1)
      Map.gen.node(map, rng, {x, y})

    map.bases = bases = for {x, y} in Map.gen.pointWeb(rng, baseCount, width, height)
      x: Math.floor(Math.min(width - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, x)))
      y: Math.floor(Math.min(height - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, y)))
    for base in bases
      Map.gen.base(map, rng, base)

    map

  Map.gen.fillRock = (map, rng, settings) ->
    fillNoise = Perlin.gen(rng.genInt24(), map.width, map.height, 
      octaves: Map.FILL_OCTAVES, amp: settings.mapAmp)
    typeNoises = for i in [0...3]
      Perlin.gen(rng.genInt24(),
        Math.ceil(map.width / Map.TYPE_SCALE) + 1,
        Math.ceil(map.height / Map.TYPE_SCALE) + 1,
        octaves: Map.TYPE_OCTAVES, amp: Map.TYPE_AMP)

    for y in [0...map.height] by 1
      for x in [0...map.width] by 1
        if fillNoise.array[y*map.width + x] > settings.mapCaveLimit
          t0 = Perlin.interpolateOctave(typeNoises[0], x/Map.TYPE_SCALE, y/Map.TYPE_SCALE)
          t1 = Perlin.interpolateOctave(typeNoises[1], x/Map.TYPE_SCALE, y/Map.TYPE_SCALE)
          t2 = Perlin.interpolateOctave(typeNoises[2], x/Map.TYPE_SCALE, y/Map.TYPE_SCALE)
          rockType =
            if t0 < t1
              if t1 < t2 then 0
              else if t0 < t2 then 1 else 4
            else
              if t2 < t1 then 5
              else if t0 < t2 then 2 else 3

          Map.set(map, x, y, Map.gen.rockSquare(rng, rockType))

    undefined

  Map.gen.rockSquare = (rng, rockType) ->
    r = rng.gen()
    if r < Map.ROCK_RATIO
      Map.rockId(rockType, Math.floor(r / Map.ROCK_RATIO * Map.ROCK_TYPE_SIZE))
    else
      Map.gen.preciousSquare(rng,)

  Map.gen.preciousSquare = (rng) ->
    switch rng.genInt(4)
      when 0 then Map.STEEL
      when 1 then Map.TITANIUM
      when 2 then Map.GOLD
      when 3 then Map.LEAD

  Map.gen.base = (map, rng, {x, y}) ->
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
    switch rng.genInt(5)
      when 0,1 then Map.gen.deposit(map, rng, pos)
      when 2 then Map.gen.chamber(map, rng, pos)
      when 3,4 then Map.gen.bunker(map, rng, pos)

  Map.gen.deposit = (map, rng, pos) ->
    count = Math.ceil(Map.DEPOSIT_COUNT * (rng.gen() + 0.5))
    square = Map.gen.preciousSquare(rng)
    for i in [0...count]
      angle = rng.gen() * 2*Math.PI
      dist = Math.ceil(Map.DEPOSIT_RADIUS * (rng.gen() + 0.5))
      x = Math.floor(Math.sin(angle) * dist + pos.x)
      y = Math.floor(Math.cos(angle) * dist + pos.y)
      if Map.contains(map, x, y) and Map.get(map, x, y) != Map.EMPTY
        Map.set(map, x, y, square)
    undefined

  Map.gen.chamber = (map, rng, pos) ->
    w = Math.ceil(Map.CHAMBER_SIZE * (rng.gen() + 0.5))
    h = Math.ceil(Map.CHAMBER_SIZE * (rng.gen() + 0.5))
    for x in [pos.x ... pos.x + w] by 1
      for y in [pos.y ... pos.y + h] by 1
        Map.set(map, x, y, Map.EMPTY) if Map.contains(map, x, y)
    undefined

  Map.gen.bunker = (map, rng, pos) ->
    w = Math.ceil(Map.BUNKER_SIZE * (rng.gen()*0.6 + 0.8))
    h = Math.ceil(Map.BUNKER_SIZE * (rng.gen()*0.6 + 0.8))

    wall = switch rng.genInt(9)
      when 0,1,2 then Map.CONCRETE
      when 3,4,5 then Map.STEEL
      when 6 then Map.TITANIUM
      when 7 then Map.LEAD
      when 8 then Map.GOLD

    for x in [pos.x .. pos.x + w - 1] by 1
      Map.setOrNothing(map, x, pos.y, wall) 
      Map.setOrNothing(map, x, pos.y + h - 1, wall) 

    for y in [pos.y .. pos.y + h - 1] by 1
      Map.setOrNothing(map, pos.x, y, wall)
      Map.setOrNothing(map, pos.x + w - 1, y, wall)

    for x in [pos.x + 1 .. pos.x + w - 2] by 1
      for y in [pos.y + 1 .. pos.y + h - 2] by 1
        Map.setOrNothing(map, x, y, Map.EMPTY)

    doorPos =
      if rng.gen() < 0.5
        doorX = pos.x + rng.genInt(w - 2) + 1
        doorY = if rng.gen() < 0.5 then pos.y else pos.y + h - 1
        [{x: doorX, y: doorY}, {x: doorX + 1, y: doorY}]
      else
        doorX = if rng.gen() < 0.5 then pos.x else pos.x + w - 1
        doorY = pos.y + rng.genInt(h - 2) + 1
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
        points[i].x -= dx * 0.01 + 5*(rng.gen() - 0.5)
        points[i].y -= dy * 0.01 + 5*(rng.gen() - 0.5)

      for i in [0...count] by 1
        for j in [i+1...count] by 1
          d = Map.dist(points[i], points[j])
          ux = dx / d
          uy = dy / d
          f = 30 / d
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


  Map.squares = new Array(256)

  Map.squares[Map.EMPTY = 0] =
    {color: "#333333"}
  Map.squares[Map.CONCRETE = 120] =
    {color: "#a3a3a3", toughness: 0.998}
  Map.squares[Map.STEEL = 130] =
    {color: "#6f7989", toughness: 0.995}
  Map.squares[Map.TITANIUM = 131] =
    {color: "#6287b2", toughness: 0.999}
  Map.squares[Map.GOLD = 132] =
    {color: "#dfbe23", toughness: 0.3, energy: 300}
  Map.squares[Map.LEAD = 133] =
    {color: "#5b7380", toughness: 0.35, mass: 50}
  Map.squares[Map.VOID = 255] =
    {color: "#000000"}

  Map.ROCK_STATS = [
    {toughness: 0.4, energy: 80, prob: 0.5}
    {toughness: 0.5, mass: 30, prob: 0.4}
    {toughness: 0.6, energy: 90, prob: 0.4}
    {toughness: 0.5, energy: 60, prob: 0.3}
    {toughness: 0.5, energy: 100, prob: 0.3}
    {toughness: 0.4, mass: 10, prob: 0.6}
  ]
  Map.ROCK_COLORS = [
    ["#a39c89", "#a79f8c", "#aaa18b", "#aea287", "#a79b7e", "#a69b83"]
    ["#a39e89", "#a7a189", "#a09a80", "#999584", "#a09c88", "#a5a08a"]
    ["#958476", "#8f7d6f", "#988473", "#9d8878", "#a68f7d", "#a79281"]
    ["#aa9c74", "#a89a72", "#ac9e76", "#ae9e75", "#a99b76", "#aea07b"]
    ["#b4b1a2", "#b8b5a4", "#bdbaa8", "#bdb9a5", "#bab69f", "#b4b19a"]

    ["#b6b19d", "#bab5a2", "#bfbaa5", "#bfbaa3", "#c3bea9", "#bdb8a3"]
  ]

  Map.ROCK_TYPE_COUNT = 6
  Map.ROCK_TYPE_SIZE = 6
  Map.rockId = (type, i) -> 10 + 10*type + i

  for t in [0...Map.ROCK_TYPE_COUNT] by 1
    for i in [0...Map.ROCK_TYPE_SIZE] by 1
      Map.squares[Map["ROCK_#{t}_#{i}"] = Map.rockId(t, i)] =
        color: Map.ROCK_COLORS[t][i]
        toughness: Map.ROCK_STATS[i].toughness
        energy: Map.ROCK_STATS[i].energy
        mass: Map.ROCK_STATS[i].mass
        prob: Map.ROCK_STATS[i].prob

  Map
