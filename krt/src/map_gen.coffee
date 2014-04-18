define ["require", "map", "perlin"], (require, Map, Perlin) ->
  MapGen = {}

  MapGen.BASE_SIZE = 8
  MapGen.BASE_DOOR_SIZE = 2
  MapGen.NODE_DENSITY = 1 / 8000
  MapGen.ROCK_RATIO = 0.997
  MapGen.SHOT_SOUND_GAIN = 0.4
  MapGen.DEPOSIT_COUNT = 10
  MapGen.DEPOSIT_RADIUS = 4
  MapGen.CHAMBER_SIZE = 8
  MapGen.BUNKER_SIZE = 6
  MapGen.FILL_OCTAVES = 4
  MapGen.TYPE_OCTAVES = 4
  MapGen.TYPE_AMP = 0.7
  MapGen.TYPE_SCALE = 8
  MapGen.WORKER_TIMEOUT = (width, height) ->
    2 + width * height / (200*200)

  MapGen.workerGen = (settings, callback) ->
    hasFinished = false
    finish = (map) ->
      unless hasFinished
        hasFinished = true
        callback(map)

    fallback = ->
      console.log("Falling back to synchronous version of map generation")
      setTimeout((-> finish(MapGen.gen(settings))), 0)

    if window.Worker?
      worker = new Worker(require.toUrl("./map_gen_worker.js"))
      worker.postMessage(settings)
      worker.onmessage = (evt) ->
        worker.terminate()
        finish(evt.data)
      worker.onerror = (evt) ->
        if evt.filename?
          console.log("Error in worker: #{evt.filename}:#{evt.lineno}: #{evt.message}")
        else
          console.log("Error in worker")
        worker.terminate()
        fallback()
      setTimeout((->
        unless hasFinished
          console.log("Worker timed out")
          fallback()
        ), MapGen.WORKER_TIMEOUT(settings.mapWidth, settings.mapHeight) * 1000)
    else
      fallback()

  MapGen.gen = (settings) ->
    width = settings.mapWidth
    height = settings.mapHeight
    baseCount = settings.playerDefs.length
    nodeCount = Math.floor(width * height * MapGen.NODE_DENSITY)

    rng = new MapGen.Rng(settings.mapSeed)
    map = Map.init(width, height)
    MapGen.fillRock(map, rng, settings)

    for {x, y} in MapGen.pointWeb(rng, nodeCount, width - 1, height - 1)
      MapGen.node(map, rng, {x, y})

    map.bases = bases = for {x, y} in MapGen.pointWeb(rng, baseCount, width, height)
      x: Math.floor(Math.min(width - MapGen.BASE_SIZE, Math.max(MapGen.BASE_SIZE, x)))
      y: Math.floor(Math.min(height - MapGen.BASE_SIZE, Math.max(MapGen.BASE_SIZE, y)))
    for base in bases
      MapGen.base(map, rng, base)

    map

  MapGen.fillRock = (map, rng, settings) ->
    fillNoise = Perlin.gen(rng.genInt24(), map.width, map.height, 
      octaves: MapGen.FILL_OCTAVES, amp: settings.mapAmp)
    typeNoises = for i in [0...3]
      Perlin.gen(rng.genInt24(),
        Math.ceil(map.width / MapGen.TYPE_SCALE) + 1,
        Math.ceil(map.height / MapGen.TYPE_SCALE) + 1,
        octaves: MapGen.TYPE_OCTAVES, amp: MapGen.TYPE_AMP)

    for y in [0...map.height] by 1
      for x in [0...map.width] by 1
        if fillNoise.array[y*map.width + x] > settings.mapCaveLimit
          t0 = Perlin.interpolateOctave(typeNoises[0], x/MapGen.TYPE_SCALE, y/MapGen.TYPE_SCALE)
          t1 = Perlin.interpolateOctave(typeNoises[1], x/MapGen.TYPE_SCALE, y/MapGen.TYPE_SCALE)
          t2 = Perlin.interpolateOctave(typeNoises[2], x/MapGen.TYPE_SCALE, y/MapGen.TYPE_SCALE)
          rockFamily =
            if t0 < t1
              if t1 < t2 then 0
              else if t0 < t2 then 1 else 4
            else
              if t2 < t1 then 5
              else if t0 < t2 then 2 else 3

          Map.set(map, x, y, MapGen.rockSquare(rng, rockFamily))

    undefined

  MapGen.rockSquare = (rng, rockFamily) ->
    r = rng.gen()
    if r < MapGen.ROCK_RATIO
      Map.rockId(rockFamily, Math.floor(r / MapGen.ROCK_RATIO * Map.ROCK_FAMILY_SIZE))
    else
      MapGen.preciousSquare(rng,)

  MapGen.preciousSquare = (rng) ->
    switch rng.genInt(4)
      when 0 then Map.STEEL
      when 1 then Map.TITANIUM
      when 2 then Map.GOLD
      when 3 then Map.LEAD

  MapGen.base = (map, rng, {x, y}) ->
    s = MapGen.BASE_SIZE

    for i in [0...s]
      Map.set(map, x+i, y, Map.TITANIUM)
      Map.set(map, x+i, y+s-1, Map.TITANIUM)
      Map.set(map, x, y+i, Map.TITANIUM)
      Map.set(map, x+s-1, y+i, Map.TITANIUM)

    for i in [1...s-1]
      for j in [1...s-1]
        Map.set(map, x+i, y+j, Map.EMPTY)

    for i in [0...MapGen.BASE_DOOR_SIZE]
      dx = x + Math.floor(s / 2 - MapGen.BASE_DOOR_SIZE / 2) + i
      Map.set(map, dx, y, Map.EMPTY)
      Map.set(map, dx, y+s-1, Map.EMPTY)

    undefined

  MapGen.node = (map, rng, pos) ->
    switch rng.genInt(5)
      when 0,1 then MapGen.deposit(map, rng, pos)
      when 2 then MapGen.chamber(map, rng, pos)
      when 3,4 then MapGen.bunker(map, rng, pos)

  MapGen.deposit = (map, rng, pos) ->
    count = Math.ceil(MapGen.DEPOSIT_COUNT * (rng.gen() + 0.5))
    square = MapGen.preciousSquare(rng)
    for i in [0...count]
      angle = rng.gen() * 2*Math.PI
      dist = Math.ceil(MapGen.DEPOSIT_RADIUS * (rng.gen() + 0.5))
      x = Math.floor(Math.sin(angle) * dist + pos.x)
      y = Math.floor(Math.cos(angle) * dist + pos.y)
      if Map.contains(map, x, y) and Map.get(map, x, y) != Map.EMPTY
        Map.set(map, x, y, square)
    undefined

  MapGen.chamber = (map, rng, pos) ->
    w = Math.ceil(MapGen.CHAMBER_SIZE * (rng.gen() + 0.5))
    h = Math.ceil(MapGen.CHAMBER_SIZE * (rng.gen() + 0.5))
    for x in [pos.x ... pos.x + w] by 1
      for y in [pos.y ... pos.y + h] by 1
        Map.set(map, x, y, Map.EMPTY) if Map.contains(map, x, y)
    undefined

  MapGen.bunker = (map, rng, pos) ->
    w = Math.ceil(MapGen.BUNKER_SIZE * (rng.gen()*0.6 + 0.8))
    h = Math.ceil(MapGen.BUNKER_SIZE * (rng.gen()*0.6 + 0.8))

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

  MapGen.pointWeb = (rng, count, width, height) ->
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
          d = MapGen.dist(points[i], points[j])
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

  MapGen.dist = (p1, p2) ->
    dx = p1.x - p2.x
    dy = p1.y - p2.y
    Math.sqrt(dx*dx + dy*dy)

  MapGen.Rng = (strSeed) ->
    [a, b, c] = [0xbeef, 0xdead, 0xb00]
    for i in [0...strSeed.length] by 1
      ch = strSeed.charCodeAt(i)
      a = c ^ (a << 13) ^ (b << 3) ^ ch
      b = a ^ (b << 15) ^ (c << 2) ^ (ch >> 1)
      c = b ^ (c << 5) ^ (a << 13) ^ ch
    @a = a; @b = b; @c = c

  MapGen.Rng::genInt24 = ->
    @a = @a ^ (((@b << 13) + (@c * 6823))|0)
    @b = @b ^ (((@c << 11) + (@a * 7727))|0)
    @c = @c ^ (((@a << 10) + (@b * 7549))|0)
    x = ((@a ^ 5297)+(@b ^ 4447))|0
    ((x * ((x * x)|0 * 3209 + 3541))&0xffffff)

  MapGen.Rng::gen = ->
    @.genInt24() / 0xffffff

  MapGen.Rng::genRange = (from, to) ->
    from + @.gen() * (to - from)

  MapGen.Rng::genInt = (limit) ->
    Math.floor(@.gen() * limit)

  MapGen.Rng::genIntRange = (from, to) ->
    @.genInt(to - from) + from

  MapGen
