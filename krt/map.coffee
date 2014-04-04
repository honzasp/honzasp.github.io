define [], ->
  Map = {}
  Map.init = (width, height) ->
    if Uint8Array?
      ary = new Uint8Array(width * height)
    else
      ary = new Array(width * height)
      for i in [0...width * height]
        ary[i] = Map.EMPTY
    { ary, width, height }

  Map.EMPTY = 0
  Map.ROCK = 1
  Map.CONCRETE = 2
  Map.STEEL = 3
  Map.VOID = 255

  Map.get = (map, x, y) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y]

  Map.set = (map, x, y, val) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y] = val

  Map.contains = (map, x, y) ->
    x >= 0 and x < map.width and y >= 0 and y < map.height

  Map
