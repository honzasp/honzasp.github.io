define ["map"], (Map) ->
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
      { x: west, y: north } = @winToMap({x: 0, y: 0})
      { x: east, y: south } = @winToMap({x: @dim.w, y: @dim.h})

      for x in [Math.floor(west) .. Math.ceil(east)]
        for y in [Math.floor(north) .. Math.ceil(south)]
          @drawTile({x, y})
      undefined

    drawObjects: ->
      @ctx.save()
      @ctx.translate(@dim.w * 0.5, @dim.h * 0.5)
      @ctx.scale(@dim.scale, @dim.scale)
      @ctx.translate(-@center.x, -@center.y)

      for i in [0...@game.tanks.length]
        @game.tanks[i].draw(@ctx)

      for i in [0...@game.bullets.length]
        unless @game.bullets[i].isDead
          @game.bullets[i].draw(@ctx)

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
