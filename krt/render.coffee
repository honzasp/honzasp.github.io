define ["map"], (Map) ->
  Render = {}

  Render.BORDER_COLOR = "#aaa"
  Render.STAT_FONT = "12px monospace"
  Render.STAT_COLOR = "#0f0"

  Render.game = (game) ->
    switch game.playerInfos.length
      when 1
        [w, h, scale] = [game.size.x, game.size.y, 16]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
      when 2
        [w, h, scale] = [game.size.x / 2, game.size.y, 14]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
        Render.window(game, game.tanks[1],
          {x: w, y: 0, w, h, scale})
      when 3
        [w, h, scale] = [game.size.x / 3, game.size.y, 13]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
        Render.window(game, game.tanks[1],
          {x: w, y: 0, w, h, scale})
        Render.window(game, game.tanks[2],
          {x: 2*w, y: 0, w, h, scale})
      when 4
        [w, h, scale] = [game.size.x / 2, game.size.y / 2, 12]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
        Render.window(game, game.tanks[1],
          {x: w, y: 0, w, h, scale})
        Render.window(game, game.tanks[2],
          {x: 0, y: h, w, h, scale})
        Render.window(game, game.tanks[3],
          {x: w, y: h, w, h, scale})
      else
        throw new Error("Unknown layout for #{game.playerInfos.length} players")

  Render.window = (game, tank, win) ->
    center = tank.pos
    ctx = game.dom.ctx

    ctx.save()
    ctx.translate(win.x, win.y)

    ctx.beginPath()
    ctx.rect(0, 0, win.w, win.h)
    ctx.strokeStyle = Render.BORDER_COLOR
    ctx.stroke()
    ctx.clip()

    ctx.save()
    ctx.translate(win.w * 0.5, win.h * 0.5)
    ctx.scale(win.scale, win.scale)
    ctx.translate(-center.x, -center.y)
    Render.map(ctx, game, win, center)
    Render.objects(ctx, game)
    ctx.restore()

    Render.stats(ctx, game, tank, win)
    ctx.restore()

  Render.objects = (ctx, game) ->
    ctx.save()

    for tank_ in game.tanks
      tank_.draw(ctx)
    for bullet in game.bullets
      bullet.draw(ctx) unless bullet.isDead
    for particle in game.particles
      particle.draw(ctx) unless particle.isDead
    for bonus in game.bonuses
      bonus.draw(ctx) unless bonus.isDead

    ctx.restore()

  Render.map = (ctx, game, win, center) ->
    { x: west, y: north } = Render.winToMap(win, center, {x: 0, y: 0})
    { x: east, y: south } = Render.winToMap(win, center, {x: win.w, y: win.h})

    xMin = Math.floor(west)
    xMax = Math.ceil(east)
    yMin = Math.floor(north)
    yMax = Math.ceil(south)
    lastSquare = undefined

    drawSquare = (x, y) ->
      square = if Map.contains(game.map, x, y)
          Map.get(game.map, x, y)
        else
          Map.VOID
      if square != lastSquare
        ctx.fillStyle = Map.squares[square].color
        lastSquare = square
      ctx.fillRect(x, y, 1, 1)

    x = xMin
    while x <= xMax
      y = yMin
      while y <= yMax
        drawSquare(x, y)
        y += 1
      x += 1
    undefined

  Render.mapToWin = (win, center, m) ->
    x: win.scale * (m.x - center.x) + win.w * 0.5
    y: win.scale * (m.y - center.y) + win.h * 0.5

  Render.winToMap = (win, center, w) ->
    x: center.x + (w.x - win.w * 0.5) / win.scale
    y: center.y + (w.y - win.h * 0.5) / win.scale

  Render.stats = (ctx, game, tank, win) ->
    info = game.playerInfos[tank.index]
    weapon = tank.weapons[tank.activeWeapon]
    progress = Array(Math.floor(weapon.temperature * 10) + 1).join(".")
    game_state = switch game.mode.mode
      when "time"
        "#{Math.max(0, Math.floor(game.mode.time - game.time))} s"
      when "lives"
        "#{game.mode.lives - info.destroyed}/#{game.mode.lives} lives"
      when "hits"
        "#{info.hits}/#{game.mode.hits} hits"

    stat = 
      "E #{Math.floor(tank.energy)} " +
      "M #{Math.floor(tank.mass)} " +
      "-#{info.destroyed}/" +
      "+#{info.hits} | " +
      "#{weapon.spec.name} " +
      "#{progress} | " +
      "#{game_state}"

    ctx.font = Render.STAT_FONT
    ctx.textAlign = "left"
    ctx.fillStyle = Render.STAT_COLOR
    ctx.fillText(stat, 5, win.h - 5)

  Render