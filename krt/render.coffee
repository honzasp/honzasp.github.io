define ["map", "tank"], (Map, Tank) ->
  Render = {}

  Render.BORDER_COLOR = "#aaa"
  Render.STAT_FONT = "12px monospace"
  Render.STAT_SHADOW_BLUR = 3
  Render.STAT_SHADOW_COLOR = "rgba(255, 239, 171, 0.5)"
  Render.STAT_MARGIN = 16
  Render.HUD_MARGIN = 5
  Render.HUD_ROW = 10
  Render.NAME_TAG_FONT = "0.8px monospace"
  Render.NAME_TAG_MARGIN = 4

  Render.game = (game) ->
    switch game.playerInfos.length
      when 1
        [w, h, scale] = [game.size.x, game.size.y, 18]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
      when 2
        [w, h, scale] = [game.size.x / 2, game.size.y, 16]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
        Render.window(game, game.tanks[1],
          {x: w, y: 0, w, h, scale})
      when 3
        [w, h, scale] = [game.size.x / 3, game.size.y, 15]
        Render.window(game, game.tanks[0],
          {x: 0, y: 0, w, h, scale})
        Render.window(game, game.tanks[1],
          {x: w, y: 0, w, h, scale})
        Render.window(game, game.tanks[2],
          {x: 2*w, y: 0, w, h, scale})
      when 4
        [w, h, scale] = [game.size.x / 2, game.size.y / 2, 14]
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

    if tank.energy < Tank.VISION_ENERGY
      ctx.globalAlpha = 1 - (Tank.VISION_ENERGY - tank.energy) / Tank.VISION_ENERGY

    ctx.save()
    ctx.translate(win.w * 0.5, win.h * 0.5)
    ctx.scale(win.scale, win.scale)
    ctx.translate(-center.x, -center.y)
    Render.map(ctx, game, win, center)
    Render.objects(ctx, game)
    ctx.restore()

    Render.stats(ctx, game, tank, win)
    Render.nameTags(ctx, game, win, center) if game.useNameTags
    ctx.restore()

  Render.objects = (ctx, game) ->
    ctx.save()

    for tank in game.tanks
      tank.draw(ctx)
    for bullet in game.bullets
      bullet.draw(ctx) unless bullet.isDead
    for particle in game.particles
      particle.draw(ctx) unless particle.isDead
    for bonus in game.bonuses
      bonus.draw(ctx) unless bonus.isDead

    ctx.restore()

  Render.nameTags = (ctx, game, win, center) ->
    for tank in game.tanks 
      name = game.playerInfos[tank.index].name
      {x, y} = Render.mapToWin(win, center, tank.pos)

      ctx.save()
      ctx.fillStyle = tank.color
      ctx.font = Render.STAT_FONT
      ctx.shadowColor = Render.STAT_SHADOW_COLOR
      ctx.shadowBlur = Render.STAT_SHADOW_BLUR
      ctx.textBaseline = "bottom"
      ctx.textAlign = "center"
      ctx.fillText(name, x, y - tank.radius*win.scale - Render.NAME_TAG_MARGIN)
      ctx.restore()
    undefined

  Render.map = (ctx, game, win, center) ->
    { x: west, y: north } = Render.winToMap(win, center, {x: 0, y: 0})
    { x: east, y: south } = Render.winToMap(win, center, {x: win.w, y: win.h})

    xMin = Math.floor(west)
    xMax = Math.ceil(east)
    yMin = Math.floor(north)
    yMax = Math.ceil(south)

    drawSquare = (x, y) ->
      square = if Map.contains(game.map, x, y)
          Map.get(game.map, x, y)
        else
          Map.VOID
      ctx.fillStyle = Map.squares[square].color
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

    coreStat = "E #{Math.floor(tank.energy)} M #{Math.floor(tank.mass)} "
    weaponStat = "#{weapon.spec.name} #{Math.ceil(weapon.temperature * 10)}"
    gameStat = "-#{info.destroyed}/+#{info.hits}  " + switch game.mode.mode
      when "time"
        "#{Math.max(0, Math.floor(game.mode.time - game.time))} s"
      when "lives"
        "#{game.mode.lives - info.destroyed}/#{game.mode.lives} lives"
      when "hits"
        "#{info.hits}/#{game.mode.hits} hits"

    ctx.save()
    ctx.font = Render.STAT_FONT
    ctx.fillStyle = tank.color
    ctx.shadowColor = Render.STAT_SHADOW_COLOR
    ctx.shadowBlur = Render.STAT_SHADOW_BLUR

    if game.useHud
      ctx.textBaseline = "top"
      ctx.textAlign = "center"
      startY = win.h/2 + tank.radius * win.scale + Render.HUD_MARGIN
      ctx.fillText(coreStat, win.w/2, startY)
      ctx.fillText(weaponStat, win.w/2, startY + Render.HUD_ROW)
      ctx.fillText(gameStat, win.w/2, startY + 2*Render.HUD_ROW)
    else
      ctx.textBaseline = "bottom"
      ctx.textAlign = "left"
      ctx.fillText(weaponStat, Render.STAT_MARGIN, win.h - Render.STAT_MARGIN)
      ctx.textAlign = "center"
      ctx.fillText(coreStat, win.w/2, win.h - Render.STAT_MARGIN)
      ctx.textAlign = "right"
      ctx.fillText(gameStat, win.w - Render.STAT_MARGIN, win.h - Render.STAT_MARGIN)

    ctx.restore()

  Render
