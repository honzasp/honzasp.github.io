"use strict"
define [], () ->
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


  Map.squares = new Array(256)

  Map.squares[Map.EMPTY = 0] =
    {color: "#333333"}
  Map.squares[Map.CONCRETE = 120] =
    {color: "#a3a3a3", toughness: 0.998, shotSound: "hit_concrete"}
  Map.squares[Map.STEEL = 130] =
    {color: "#6f7989", toughness: 0.995, shotSound: "hit_metal"}
  Map.squares[Map.TITANIUM = 131] =
    {color: "#6287b2", toughness: 0.999, shotSound: "hit_metal"}
  Map.squares[Map.GOLD = 132] =
    {color: "#dfbe23", toughness: 0.3, energy: 300, shotSound: "hit_metal"}
  Map.squares[Map.LEAD = 133] =
    {color: "#5b7380", toughness: 0.35, mass: 50, shotSound: "hit_metal"}
  Map.squares[Map.VOID = 255] =
    {color: "#000000"}

  Map.ROCK_STATS = [
    {toughness: 0.4, energy: 80, prob: 0.5, shotSound: "hit_rock"}
    {toughness: 0.5, mass: 30, prob: 0.4, shotSound: "hit_rock"}
    {toughness: 0.6, energy: 90, prob: 0.4, shotSound: "hit_rock"}
    {toughness: 0.5, energy: 60, prob: 0.3, shotSound: "hit_rock"}
    {toughness: 0.5, energy: 100, prob: 0.3, shotSound: "hit_rock"}
    {toughness: 0.4, mass: 10, prob: 0.6, shotSound: "hit_rock"}
  ]
  Map.ROCK_COLORS = [
    ["#a39c89", "#a79f8c", "#aaa18b", "#aea287", "#a79b7e", "#a69b83"]
    ["#a39e89", "#a7a189", "#a09a80", "#999584", "#a09c88", "#a5a08a"]
    ["#958476", "#8f7d6f", "#988473", "#9d8878", "#a68f7d", "#a79281"]
    ["#aa9c74", "#a89a72", "#ac9e76", "#ae9e75", "#a99b76", "#aea07b"]
    ["#b4b1a2", "#b8b5a4", "#bdbaa8", "#bdb9a5", "#bab69f", "#b4b19a"]
    ["#b6b19d", "#bab5a2", "#bfbaa5", "#bfbaa3", "#c3bea9", "#bdb8a3"]
  ]

  Map.ROCK_FAMILY_COUNT = 6
  Map.ROCK_FAMILY_SIZE = 6
  Map.rockId = (type, i) -> 10 + 10*type + i

  genRocks = ->
    for t in [0...Map.ROCK_FAMILY_COUNT] by 1
      for i in [0...Map.ROCK_FAMILY_SIZE] by 1
        Map.squares[Map["ROCK_#{t}_#{i}"] = Map.rockId(t, i)] =
          color: Map.ROCK_COLORS[t][i]
          toughness: Map.ROCK_STATS[i].toughness
          energy: Map.ROCK_STATS[i].energy
          mass: Map.ROCK_STATS[i].mass
          prob: Map.ROCK_STATS[i].prob
          shotSound: Map.ROCK_STATS[i].shotSound
    undefined
  genRocks()

  optimizeSquares = ->
    for s in [0...256] by 1
      if Map.squares[s]?
        Map.squares[s].color ||= undefined
        Map.squares[s].toughness ||= undefined
        Map.squares[s].prob ||= undefined
        Map.squares[s].energy ||= undefined
        Map.squares[s].mass ||= undefined
        Map.squares[s].shotSound ||= undefined
    undefined
  optimizeSquares()

  Map
