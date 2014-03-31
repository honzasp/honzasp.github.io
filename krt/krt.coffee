$ ->
  class Menu
    constructor: (@$root) ->
      @$menu = $("<div></div>").appendTo(@$root)
      @$playBtn = $("<button>Play</button>").appendTo(@$menu)

      @$playBtn.click => @play()

    play: ->
      settings = 
        "fps": 20
        "map width": 100
        "map height": 50

      if !@game?
        @game = new Game(@$root, settings)
        @game.start()

  class Game
    constructor: ($root, @settings) ->
      @dom = {}
      @dom.$root = $root
      @dom.$main = $("<div />").appendTo(@dom.$root)
      @dom.$canvas = $("<canvas />").appendTo(@dom.$main)

      @map = new Map(@settings["map width"], @settings["map height"])
      @map.set(2, 3, Map.ROCK)
      @map.set(4, 3, Map.ROCK)

      @ctx = @dom.$canvas[0].getContext("2d")
      @resize(800, 600)

      @tanks = [new Tank(@, 1.8, 2.0)]
      @tanks[0].vel = {x: 0.6, y: 0.9}

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
      for i in [0...@tanks.length]
        @tanks[i].update(t)
      undefined

    start: ->
      setInterval((=> @tick()), 1000 * @tickLen)

  class Window
    constructor: (@game, @center, @dim) ->
      @ctx = @game.ctx

      @ctx.save()
      @ctx.translate(@dim.x, @dim.y)
      @ctx.beginPath()
      @ctx.rect(0, 0, @dim.w, @dim.h)
      @ctx.clip()

      @drawTiles()
      @drawObjects()

      @ctx.restore()

    drawTiles: ->
      { x: left, y: top } = @winToMap({x: 0, y: 0})
      { x: right, y: bot } = @winToMap({x: @dim.w, y: @dim.h})

      for x in [Math.floor(left) .. Math.ceil(right)]
        for y in [Math.floor(top) .. Math.ceil(bot)]
          @drawTile({x, y})
      undefined

    drawObjects: ->
      @ctx.save()
      @ctx.translate(@dim.w * 0.5, @dim.h * 0.5)
      @ctx.scale(@dim.scale, @dim.scale)
      @ctx.translate(-@center.x, -@center.y)

      for i in [0...@game.tanks.length]
        @game.tanks[i].draw(@ctx)

      @ctx.restore()

    drawTile: (pos) ->
      winPos = @mapToWin(pos)
      @ctx.fillStyle = @tileColor(@game.map.get(pos.x, pos.y))
      @ctx.fillRect(winPos.x, winPos.y, @dim.scale+0.5, @dim.scale+0.5)

    tileColor: (tile) ->
      switch tile
        when Map.EMPTY
          "#333"
        when Map.ROCK
          "#aaa"
        when Map.CONCRETE
          "#ccc"
        when Map.VOID
          "#000"
        else
          "#f00"

    mapToWin: (m) ->
      x: @dim.scale * (m.x - @center.x) + @dim.w * 0.5
      y: @dim.scale * (m.y - @center.y) + @dim.h * 0.5

    winToMap: (w) ->
      x: @center.x + (w.x - @dim.w * 0.5) / @dim.scale
      y: @center.y + (w.y - @dim.h * 0.5) / @dim.scale

    drawCircle: (pos, radius) ->
      winPos = @mapToWin(pos)
      winRadius = radius * @dim.scale
      @ctx.beginPath()
      @ctx.fillStyle = "#f00"
      @ctx.arc(winPos.x, winPos.y, winRadius, 0, Math.PI*2)
      @ctx.fill()

  class Tank
    @RADIUS = 0.6

    constructor: (@game, x, y) ->
      @rot = 0
      @pos = { x, y }
      @vel = { x: 0, y: 0 }

    update: (t) ->
      @pos =
        x: @pos.x + @vel.x * t
        y: @pos.y + @vel.y * t

      hit = (x,y) => @game.map.get(Math.floor(x), Math.floor(y)) != Map.EMPTY

      if hit(@pos.x + Tank.RADIUS, @pos.y)
        @pos.x = Math.floor(@pos.x + Tank.RADIUS) - Tank.RADIUS
        @vel.x = -@vel.x
      else if hit(@pos.x - Tank.RADIUS, @pos.y)
        @pos.x = Math.floor(@pos.x - Tank.RADIUS) + 1 + Tank.RADIUS
        @vel.x = -@vel.x

      if hit(@pos.x, @pos.y + Tank.RADIUS)
        @pos.y = Math.floor(@pos.y + Tank.RADIUS) - Tank.RADIUS
        @vel.y = -@vel.y
      else if hit(@pos.x, @pos.y - Tank.RADIUS)
        @pos.y = Math.floor(@pos.y - Tank.RADIUS) + 1 + Tank.RADIUS
        @vel.y = -@vel.y

    draw: (ctx) ->
      ctx.save()
      ctx.translate(@pos.x, @pos.y)
      ctx.rotate(@rot)
      ctx.scale(Tank.RADIUS, Tank.RADIUS)

      ctx.beginPath()
      ctx.arc(0, 0, 1.0, 0, Math.PI*2)
      ctx.fillStyle = "#d33"
      ctx.fill()

      ctx.beginPath()
      ctx.moveTo( 0.0, -0.6)
      ctx.lineTo(-0.4,  0.4)
      ctx.lineTo( 0.4,  0.4)
      ctx.lineTo( 0.0, -0.6)
      ctx.fillStyle = "#a00"
      ctx.fill()

      ctx.restore()


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

  new Menu($("#krt"))
