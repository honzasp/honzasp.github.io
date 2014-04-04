define ["map", "tank", "bullet"], (Map, Tank, Bullet) ->
  Window = {}
  Window.draw = (game, center, dim) ->
    ctx = game.dom.ctx

    mapToWin = (m) ->
      x: dim.scale * (m.x - center.x) + dim.w * 0.5
      y: dim.scale * (m.y - center.y) + dim.h * 0.5

    winToMap = (w) ->
      x: center.x + (w.x - dim.w * 0.5) / dim.scale
      y: center.y + (w.y - dim.h * 0.5) / dim.scale

    drawObjects = ->
      ctx.save()

      for i in [0...game.tanks.length]
        Tank.draw(game.tanks[i], ctx)

      for i in [0...game.bullets.length]
        unless game.bullets[i].isDead
          Bullet.draw(game.bullets[i], ctx)

      ctx.restore()

    drawTiles = ->
      { x: west, y: north } = winToMap({x: 0, y: 0})
      { x: east, y: south } = winToMap({x: dim.w, y: dim.h})

      for x in [Math.floor(west) .. Math.ceil(east)]
        for y in [Math.floor(north) .. Math.ceil(south)]
          drawTile({x, y})
      undefined

    drawTile = (pos) ->
      ctx.fillStyle = if Map.contains(game.map, pos.x, pos.y)
          tileColor(Map.get(game.map, pos.x, pos.y))
        else
          "#000"
      ctx.fillRect(pos.x, pos.y, 1, 1)

    ctx.save()
    ctx.translate(dim.x, dim.y)

    ctx.strokeStyle = "#ddd"
    ctx.strokeRect(0, 0, dim.w, dim.h)

    ctx.beginPath()
    ctx.rect(0, 0, dim.w, dim.h)
    ctx.clip()

    ctx.translate(dim.w * 0.5, dim.h * 0.5)
    ctx.scale(dim.scale, dim.scale)
    ctx.translate(-center.x, -center.y)

    drawTiles()
    drawObjects()

    ctx.restore()

  tileColor = (tile) ->
    switch tile
      when Map.EMPTY
        "#333"
      when Map.STEEL
        "#558"
      when Map.ROCK
        "#aaa"
      when Map.CONCRETE
        "#ccc"
      else
        "#f00"

  Window
