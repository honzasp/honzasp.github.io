"use strict"
define ["map", "tank"], (Map, Tank) ->
  Render = {}

  Render.BORDER_COLOR = "#aaa"
  Render.STAT_FONT = "12px monospace"
  Render.STAT_SHADOW_BLUR = 3
  Render.STAT_SHADOW_COLOR = "rgba(255, 239, 171, 0.5)"
  Render.STAT_MARGIN = 16
  Render.HUD_MARGIN = 5
  Render.HUD_ROW = 12
  Render.NAME_TAG_FONT = "0.8px monospace"
  Render.NAME_TAG_MARGIN = 4

  Render.game = (game) ->
    switch game.playerInfos.length
      when 1
        [w, h, scale] = [game.size.x, game.size.y, 17]
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
    center = 
      x: tank.pos.x, y: tank.pos.y
      angle: if game.rotateViewport then tank.angle + Math.PI else 0
    ctx = game.dom.ctx

    ctx.save()
    ctx.translate(win.x, win.y)

    ctx.beginPath()
    ctx.rect(0, 0, win.w, win.h)
    ctx.strokeStyle = Render.BORDER_COLOR
    ctx.stroke()
    ctx.clip()

    if tank.energy < Tank.VISION_ENERGY
      ctx.globalAlpha *= 1 - 0.8*(Tank.VISION_ENERGY-tank.energy)/Tank.VISION_ENERGY

    ctx.save()
    ctx.translate(win.w * 0.5, win.h * 0.5)
    ctx.rotate(center.angle) if game.rotateViewport
    ctx.scale(win.scale, win.scale)
    ctx.translate(-center.x, -center.y)
    Render.map(ctx, game, win, center)
    Render.objects(ctx, game)
    Render.nameTags(ctx, game, win, center) if game.useNameTags
    ctx.restore()

    Render.stats(ctx, game, tank, win)
    ctx.restore()

  Render.objects = (ctx, game) ->
    ctx.save()

    for tank in game.tanks
      tank.render(ctx)
    for bullet in game.bullets
      bullet.render(ctx) unless bullet.isDead
    for particle in game.particles
      particle.render(ctx) unless particle.isDead
    for bonus in game.bonuses
      bonus.render(ctx) unless bonus.isDead

    ctx.restore()

  Render.nameTags = (ctx, game, win, center) ->
    for tank in game.tanks 
      name = game.playerInfos[tank.index].name
      {x, y} = tank.pos

      ctx.save()
      ctx.translate(x, y)
      ctx.scale(1 / win.scale, 1 / win.scale)
      ctx.rotate(-center.angle)
      ctx.fillStyle = tank.color
      ctx.font = Render.STAT_FONT
      ctx.shadowColor = Render.STAT_SHADOW_COLOR
      ctx.shadowBlur = Render.STAT_SHADOW_BLUR
      ctx.textBaseline = "bottom"
      ctx.textAlign = "center"
      ctx.fillText(name, 0, -tank.radius*win.scale - Render.NAME_TAG_MARGIN)
      ctx.restore()
    undefined

  Render.map = (ctx, game, win, center) ->
    renderSquare = (x, y) ->
      square = if Map.contains(game.map, x, y)
          Map.get(game.map, x, y)
        else
          Map.VOID
      ctx.fillStyle = Map.squares[square].color
      ctx.fillRect(x, y, 1, 1)

    if game.rotateViewport
      horizLen = 0.5 * win.w / win.scale + Math.sqrt(2)
      vertLen = 0.5 * win.h / win.scale + Math.sqrt(2)
      horizX = horizLen * Math.cos(center.angle)
      horizY = -horizLen * Math.sin(center.angle)
      vertX = -vertLen * Math.sin(center.angle)
      vertY = -vertLen * Math.cos(center.angle)
      radius = 0.5 * Math.sqrt(win.w*win.w + win.h*win.h) / win.scale

      for y in [Math.floor(center.y - radius) .. Math.floor(center.y + radius)] by 1
        for x in [Math.floor(center.x - radius) .. Math.floor(center.x + radius)] by 1
          pX = x - center.x
          pY = y - center.y
          a = (vertY*pX - vertX*pY) / (vertY*horizX - vertX*horizY)
          b = (horizY*pX - horizX*pY) / (horizY*vertX - horizX*vertY)
          if a >= -1 and a <= 1 and b >= -1 and b <= 1
            renderSquare(x, y)

    else
      west = center.x - 0.5 * win.w / win.scale
      east = center.x + 0.5 * win.w / win.scale
      north = center.y - 0.5 * win.h / win.scale
      south = center.y + 0.5 * win.h / win.scale

      for y in [Math.floor(north) .. Math.floor(south)] by 1
        for x in [Math.floor(west) .. Math.floor(east)] by 1
          renderSquare(x, y)

    undefined

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
