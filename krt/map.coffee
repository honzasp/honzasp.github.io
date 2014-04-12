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
    {color: "#333"}
  Map.squares[Map.ROCK_1 = 10] =
    {color: "#aaa", toughness: 0.4, energy: 60}
  Map.squares[Map.ROCK_2 = 11] =
    {color: "#bbb", toughness: 0.5, mass: 30}
  Map.squares[Map.ROCK_3 = 12] =
    {color: "#ccc", toughness: 0.6, energy: 40, mass: 20}
  Map.squares[Map.ROCK_4 = 13] =
    {color: "#ddd", toughness: 0.5, energy: 60}
  Map.squares[Map.ROCK_5 = 14] =
    {color: "#eee", toughness: 0.5, energy: 40}
  Map.squares[Map.ROCK_6 = 15] =
    {color: "#999", toughness: 0.4, mass: 10}
  Map.squares[Map.CONCRETE = 20] =
    {color: "#ccc", toughness: 0.8}
  Map.squares[Map.STEEL = 30] =
    {color: "#669", toughness: 0.9}
  Map.squares[Map.TITANIUM = 31] =
    {color: "#558", toughness: 0.99}
  Map.squares[Map.GOLD = 32] =
    {color: "#ff0", toughness: 0.3, energy: 300}
  Map.squares[Map.VOID = 255] =
    {color: "#000"}

  Map.get = (map, x, y) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y]

  Map.set = (map, x, y, val) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y] = val

  Map.contains = (map, x, y) ->
    throw new Error("only integer coordinates allowed") unless x == Math.floor(x) and y == Math.floor(y)
    x >= 0 and x < map.width and y >= 0 and y < map.height

  Map.BASE_SIZE = 8
  Map.BASE_DOOR_SIZE = 2
  Map.NODE_DENSITY = 0 / 3000
  Map.ROCK_RATIO = 0.999
  Map.TUNNEL_MAX_WIDTH = 4
  Map.TUNNEL_DENSITY = 0.0
  Map.TUNNEL_SHORTEN_ATTEMPTS = 10

  Map.gen = (settings) ->
    width = settings.mapWidth
    height = settings.mapHeight
    baseCount = settings.playerDefs.length
    nodeCount = Math.floor(width * height * Map.NODE_DENSITY)

    map = Map.init(width, height)
    Map.gen.fillRock(map)

    map.bases = bases = for {x, y} in Map.gen.pointWeb(baseCount, width - 1, height - 1)
      x: Math.floor(Math.min(width - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, x)))
      y: Math.floor(Math.min(height - Map.BASE_SIZE, Math.max(Map.BASE_SIZE, y)))
    for base in bases
      Map.gen.base(map, base)

    map

  Map.gen.fillRock = (map) ->
    perlin = Perlin.gen(0xbeef, map.width, map.height, octaves: 4, amp: 0.4)
    for y in [0...map.height] by 1
      for x in [0...map.width] by 1
        if perlin[y*map.width + x] > 0
          Map.set(map, x, y, Map.gen.rockSquare())
    undefined

  Map.gen.rockSquare = ->
    r = Math.random()
    if r < Map.ROCK_RATIO
      switch Math.floor(r / Map.ROCK_RATIO * 6)
        when 0 then Map.ROCK_1
        when 1 then Map.ROCK_2
        when 2 then Map.ROCK_3
        when 3 then Map.ROCK_4
        when 4 then Map.ROCK_5
        when 5 then Map.ROCK_6
    else
      switch Math.floor((r - Map.ROCK_RATIO) / (1 - Map.ROCK_RATIO) * 3)
        when 0 then Map.STEEL
        when 1 then Map.TITANIUM
        when 2 then Map.GOLD

  Map.gen.base = (map, base) ->
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

  Map.gen.pointWeb = (count, width, height) ->
    points = for i in [0...count] by 1
      {x: Math.random()*width, y: Math.random()*height}

    clampX = (x) -> Math.max(0, Math.min(width, x))
    clampY = (y) -> Math.max(0, Math.min(height, y))

    for t in [0...100] by 1
      for i in [0...count] by 1
        dx = points[i].x - width / 2
        dy = points[i].y - height / 2
        points[i].x -= dx * 0.02 + 5*(Math.random() - 0.5)
        points[i].y -= dy * 0.02 + 5*(Math.random() - 0.5)

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

  Map
