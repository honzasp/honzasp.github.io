define ["map"], (Map) ->
  Window = {}

  Window.BORDER_COLOR = "#aaa"
  Window.STAT_FONT = "12px monospace"
  Window.STAT_COLOR = "#0f0"

  Window.draw = (game, center, tank, dim) ->
    ctx = game.dom.ctx

    mapToWin = (m) ->
      x: dim.scale * (m.x - center.x) + dim.w * 0.5
      y: dim.scale * (m.y - center.y) + dim.h * 0.5

    winToMap = (w) ->
      x: center.x + (w.x - dim.w * 0.5) / dim.scale
      y: center.y + (w.y - dim.h * 0.5) / dim.scale

    drawObjects = -> do ->
      ctx.save()

      for tank1 in game.tanks
        tank1.draw(ctx)
      for bullet in game.bullets
        bullet.draw(ctx) unless bullet.isDead
      for particle in game.particles
        particle.draw(ctx) unless particle.isDead

      ctx.restore()

    drawTiles = ->
      { x: west, y: north } = winToMap({x: 0, y: 0})
      { x: east, y: south } = winToMap({x: dim.w, y: dim.h})

      xMin = Math.floor(west)
      xMax = Math.ceil(east)
      yMin = Math.floor(north)
      yMax = Math.ceil(south)

      x = xMin
      while x <= xMax
        y = yMin
        while y <= yMax
          drawTile(x, y)
          y += 1
        x += 1
      undefined

    lastSquare = undefined
    drawTile = (x, y) ->
      square = if Map.contains(game.map, x, y)
          Map.get(game.map, x, y)
        else
          Map.VOID
      if square != lastSquare
        ctx.fillStyle = Map.squares[square].color
        lastSquare = square
      ctx.fillRect(x, y, 1, 1)

    if tank?
      drawStats = ->
        info = game.playerInfos[tank.index]
        weapon = tank.weapons[tank.activeWeapon]
        progress = Array(Math.floor(weapon.temperature * 10) + 1).join(".")
        stat = 
          "E #{Math.floor(tank.energy)} " +
          "L #{info.lives} " +
          "H #{info.hits} | " +
          "#{weapon.spec.name} " +
          "#{progress}"

        ctx.font = Window.STAT_FONT
        ctx.textAlign = "left"
        ctx.fillStyle = Window.STAT_COLOR
        ctx.fillText(stat, 5, dim.h - 5)
    else
      drawStats = ->

    ctx.save()
    ctx.translate(dim.x, dim.y)

    ctx.strokeStyle = Window.BORDER_COLOR
    ctx.strokeRect(0, 0, dim.w, dim.h)

    ctx.beginPath()
    ctx.rect(0, 0, dim.w, dim.h)
    ctx.clip()

    ctx.save()
    ctx.translate(dim.w * 0.5, dim.h * 0.5)
    ctx.scale(dim.scale, dim.scale)
    ctx.translate(-center.x, -center.y)
    drawTiles()
    drawObjects()
    ctx.restore()

    drawStats()
    ctx.restore()

  Window
