define ["map", "tank", "bullet", "particle"], (Map, Tank, Bullet, Particle) ->
  Window = {}

  Window.borderColor = "#aaa"

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

      for i in [0...game.particles.length]
        unless game.particles[i].isDead
          Particle.draw(game.particles[i], ctx)

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
          Map.squares[Map.get(game.map, pos.x, pos.y)]?.color || "#f0f"
        else
          Map.voidSquare.color
      ctx.fillRect(pos.x, pos.y, 1, 1)

    ctx.save()
    ctx.translate(dim.x, dim.y)

    ctx.strokeStyle = Window.borderColor
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

  Window
