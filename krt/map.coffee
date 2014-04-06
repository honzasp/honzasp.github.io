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
  Map.TITANIUM = 4

  Map.squares = []
  Map.squares[Map.EMPTY]    = {color: "#333"}
  Map.squares[Map.ROCK]     = {color: "#aaa", toughness: 0.4}
  Map.squares[Map.CONCRETE] = {color: "#ccc", toughness: 0.8}
  Map.squares[Map.STEEL]    = {color: "#669", toughness: 0.9}
  Map.squares[Map.TITANIUM] = {color: "#558", toughness: 0.99}

  Map.voidSquare = {color: "#000"}

  Map.get = (map, x, y) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y]

  Map.set = (map, x, y, val) ->
    throw new Error("position out of map") unless Map.contains(map, x, y)
    map.ary[x * map.height + y] = val

  Map.contains = (map, x, y) ->
    throw new Error("only integer coordinates allowed") unless x == Math.floor(x) and y == Math.floor(y)
    x >= 0 and x < map.width and y >= 0 and y < map.height

  Map
