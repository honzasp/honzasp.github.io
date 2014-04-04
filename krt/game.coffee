define ["jquery", "map", "window", "tank", "collisions"], \
($, Map, Window, Tank, Collisions) ->
  class Game
    @MAX_GARBAGE_RATIO = 0.5

    constructor: ($root, @settings) ->
      @dom = {}
      @dom.$root = $root
      @dom.$main = $("<div />").appendTo(@dom.$root)
      @dom.$canvas = $("<canvas />").appendTo(@dom.$main)

      @map = new Map(@settings["map width"], @settings["map height"])
      for y in [2..20]
        for x in [3..13]
          @map.set(x, y, Map.ROCK)
      @map.set(4, 3, Map.ROCK)

      @ctx = @dom.$canvas[0].getContext("2d")
      @resize(800, 600)

      @tanks = [new Tank(@, {x:1.8, y:2.0}), new Tank(@, {x:3.0, y:1.2})]
      @bullets = []

      $(document).keydown (evt) =>
        switch evt.which
          when 87 # w
            @tanks[0].acc = 1
          when 83 # s
            @tanks[0].acc = -1
          when 65 # a
            @tanks[0].rot = 1
          when 68 # d
            @tanks[0].rot = -1
          when 81 # q
            @tanks[0].fire(@)

      $(document).keyup (evt) =>
        switch evt.which
          when 87 # w
            @tanks[0].acc = 0 if @tanks[0].acc > 0
          when 83 # s
            @tanks[0].acc = 0 if @tanks[0].acc < 0
          when 65 # a
            @tanks[0].rot = 0 if @tanks[0].rot > 0
          when 68 # d
            @tanks[0].rot = 0 if @tanks[0].rot < 0

      @tickLen = 1.0 / @settings["fps"]

    resize: (width, height) ->
      @dom.$canvas.attr("width", width)
      @dom.$canvas.attr("height", height)
      @dim = { width, height }

    tick: ->
      @update(@tickLen)
      @draw()

    draw: ->
      new Window(@, @tanks[0].pos, x: 0, y: 0, w: @dim.width, h: @dim.height, scale: 16)

    update: (t) ->
      @updateTanks(t)
      @updateBullets(t)

    updateBullets: (t) ->
      deadCount = 0
      for i in [0...@bullets.length]
        unless @bullets[i].isDead
          Collisions.bullet(@bullets[i], t, @map, @tanks)
          @bullets[i].update(t)
        else
          deadCount += 1

      if deadCount > @bullets * Game.MAX_GARBAGE_RATIO
        p = 0
        for i in [0...@bullets.length]
          unless @bullets[i].isDead
            @bullets[p] = @bullets[i]
            p = p + 1
        @bullets.length = p

    updateTanks: (t) ->
      for i in [0...@tanks.length]
        @tanks[i].update(t)

      for i in [0...@tanks.length]
        for j in [i+1...@tanks.length]
          Collisions.tankTank(@tanks[i], @tanks[j])

      for i in [0...@tanks.length]
        Collisions.tankMap(@tanks[i], @map)

      undefined

    start: ->
      setInterval((=> @tick()), 1000 * @tickLen)

