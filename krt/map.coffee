define [], ->
  class Map
    @EMPTY: 0
    @ROCK: 1
    @CONCRETE: 2
    @STEEL: 3
    @VOID: 255

    constructor: (@width, @height) ->
      @ary = if Uint8Array?
          new Uint8Array(@width * @height)
        else
          ary = new Array(@width * @height)
          for i in [0...@width * height]
            ary[i] = Map.EMPTY
          ary

    get: (x, y) ->
      if x >= 0 and x < @width and y >= 0 and y < @height
        @ary[x * @height + y]
      else
        Map.VOID

    set: (x, y, val) ->
      if x >= 0 and x < @width and y >= 0 and y < @height
        @ary[x * @height + y] = val

