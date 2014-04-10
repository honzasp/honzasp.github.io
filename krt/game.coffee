define ["exports", "jquery", "map", "window", "tank", "bullet", "particle", "collisions"], \
(exports, $, Map, Window, Tank, Bullet, Particle, Collisions) ->
  Game = exports
  Game.MAX_GARBAGE_RATIO = 0.5
  Game.BASE_SIZE = 8
  Game.BASE_DOOR_SIZE = 2

  Game.init = (settings, callback) ->
    playerInfos = Game.init.createPlayers(settings)
    game = 
      dom: Game.init.prepareDom(game)
      map: Game.init.createMap(settings, playerInfos)
      tanks: Game.createTank(game, info) for info in playerInfos
      bullets: []
      particles: []
      bonuses: []
      size: {x: 800, y: 600}
      events: undefined
      tickLen: 1.0 / settings["fps"]
      timer: undefined
      playerInfos: playerInfos
      callback: callback
      mode: settings.mode
      time: 0

    Game.resizeCanvas(game)
    Game.rebindListeners(game)
    game

  Game.init.prepareDom = (game) ->
    $oldBody = $("body").detach()
    $body = $("<body>").appendTo($("html"))
    $main = $("<div>").appendTo($body)
    $canvas = $("<canvas>").appendTo($main)
    $canvas.css
      "display": "block"
      "position": "fixed"
      "top": "0px"
      "left": "0px"
      "margin": "0px"
      "padding": "0px"
    ctx = $canvas[0].getContext("2d")

    { $body, $oldBody, $main, $canvas, ctx, $pauseBox: undefined }

  Game.init.createPlayers = (settings) ->
    for def, idx in settings.playerDefs
      x = Math.floor(Math.random() * (settings.mapWidth - Game.BASE_SIZE))
      y = Math.floor(Math.random() * (settings.mapHeight - Game.BASE_SIZE))
      {index: idx, base: {x, y}, destroyed: 0, hits: 0, keys: def.keys, color: def.color}

  Game.init.createMap = (settings, playerInfos) ->
    map = Map.init(settings.mapWidth, settings.mapHeight)
    for y in [2..20]
      for x in [3..13]
        Map.set(map, x, y, Map.ROCK)
    Map.set(map, 4, 3, Map.STEEL)

    for playerInfo in playerInfos
      {base: {x, y}} = playerInfo
      s = Game.BASE_SIZE

      for i in [0...s]
        Map.set(map, x+i, y, Map.TITANIUM)
        Map.set(map, x+i, y+s-1, Map.TITANIUM)
        Map.set(map, x, y+i, Map.TITANIUM)
        Map.set(map, x+s-1, y+i, Map.TITANIUM)

      for i in [1...s-1]
        for j in [1...s-1]
          Map.set(map, x+i, y+j, Map.EMPTY)

      for i in [0...Game.BASE_DOOR_SIZE]
        dx = x + Math.floor(s / 2 - Game.BASE_DOOR_SIZE / 2) + i
        Map.set(map, dx, y, Map.EMPTY)
        Map.set(map, dx, y+s-1, Map.EMPTY)

    map

  Game.createTank = (game, playerInfo) ->
    {index: idx, base: {x, y}, color} = playerInfo
    new Tank(idx, x+Game.BASE_SIZE/2, y+Game.BASE_SIZE/2, 0, color)

  Game.deinit = (game) ->
    Game.stop(game)
    Game.unbindListeners(game)
    game.dom.$body.remove()
    game.dom.$oldBody.appendTo($("html"))
    game.callback()

  Game.tankDestroyed = (game, index, guilty = undefined) ->
    game.tanks[index] = Game.createTank(game, game.playerInfos[index])
    game.playerInfos[guilty].hits += 1 if guilty?
    game.playerInfos[index].destroyed += 1
    switch game.mode.mode
      when "lives"
        if game.playerInfos[index].destroyed >= game.mode.lives
          Game.finish(game)
      when "hits"
        if guilty? and game.playerInfos[guilty].hits >= game.mode.hits
          Game.finish(game)

    if game.playerInfos[index].lives <= 0
      Game.finish(game)

  Game.rebindListeners = (game) ->
    Game.unbindListeners(game) if game.events?
    game.events = Game.events(game)
    $(window).on(game.events)

  Game.unbindListeners = (game) ->
    return unless game.events?
    $(window).off(game.events)
    game.events = undefined

  Game.events = (game) ->
    forwardOn  = (idx) -> game.tanks[idx].acc = 1
    backwardOn = (idx) -> game.tanks[idx].acc = -1
    leftOn     = (idx) -> game.tanks[idx].rot = 1
    rightOn    = (idx) -> game.tanks[idx].rot = -1
    fireOn     = (idx) -> game.tanks[idx].firing = true
    changeOn   = (idx) -> game.tanks[idx].change()

    forwardOff  = (idx) -> game.tanks[idx].acc = 0 if game.tanks[idx].acc > 0
    backwardOff = (idx) -> game.tanks[idx].acc = 0 if game.tanks[idx].acc < 0
    leftOff     = (idx) -> game.tanks[idx].rot = 0 if game.tanks[idx].rot > 0
    rightOff    = (idx) -> game.tanks[idx].rot = 0 if game.tanks[idx].rot < 0
    fireOff     = (idx) -> game.tanks[idx].firing = false

    keydown: (evt) ->
      if evt.which == 27
        Game.pause(game)

      for {keys}, idx in game.playerInfos
        forwardOn(idx) if evt.which == keys.forward
        backwardOn(idx) if evt.which == keys.backward
        leftOn(idx) if evt.which == keys.left
        rightOn(idx) if evt.which == keys.right
        fireOn(idx) if evt.which == keys.fire
        changeOn(idx) if evt.which == keys.change
      undefined

    keyup: (evt) ->
      for {keys}, idx in game.playerInfos
        forwardOff(idx) if evt.which == keys.forward
        backwardOff(idx) if evt.which == keys.backward
        leftOff(idx) if evt.which == keys.left
        rightOff(idx) if evt.which == keys.right
        fireOff(idx) if evt.which == keys.fire
      undefined

    resize: (evt) ->
      Game.resizeCanvas(game)

  Game.resizeCanvas = (game) ->
    game.size.x = window.innerWidth
    game.size.y = window.innerHeight
    game.dom.$canvas.attr("width", game.size.x)
    game.dom.$canvas.attr("height", game.size.y)
    Game.draw(game)

  Game.start = (game) ->
    Game.stop(game) if game.timer?
    game.timer = setInterval((-> Game.tick(game)), game.tickLen * 1000)

  Game.stop = (game) ->
    clearInterval(game.timer) if game.timer?
    game.timer = undefined

  Game.pause = (game) ->
    Game.stop(game)
    Game.unbindListeners(game)
    game.dom.$pauseBox?.remove()
    game.dom.$pauseBox = Game.pause.createBox(game)

  Game.pause.createBox = (game) ->
    $box = $("<div class='pause-box' />").appendTo(game.dom.$main)
    $box.css
      "position": "absolute"
      "top": "100px"
      "left": "100px"
      "background": "#fff"

    $resumeBtn = $("<input type='button' name='resume' value='Resume'>").appendTo($box)
    $quitBtn = $("<input type='button' name='quit' value='Quit'>").appendTo($box)
    $quitBtn.attr("disabled", "disabled")
    setTimeout((-> $quitBtn.removeAttr("disabled")), 1500)

    Game.createResults(game).appendTo($box)

    $resumeBtn.click -> Game.resume(game)
    $quitBtn.click -> Game.deinit(game)

    $box

  Game.resume = (game) ->
    game.dom.$pauseBox?.remove()
    game.dom.$pauseBox = undefined
    Game.rebindListeners(game)
    Game.start(game)

  Game.finish = (game) ->
    Game.stop(game)
    $box = $("<div class='finish-box' />").appendTo(game.dom.$main)
    $box.css
      "position": "absolute"
      "top": "100px"
      "left": "100px"
      "background": "#fff"

    Game.createResults(game).appendTo($box)
    $okBtn = $("<input type='button' name='ok' value='Ok'>").appendTo($box)
    $okBtn.click -> Game.deinit(game)

  Game.createResults = (game) ->
    $list = $("<ul />")
    for info in game.playerInfos
      $("<li />")\
        .text("#{info.index}: -#{info.destroyed}/+#{info.hits}")\
        .appendTo($list)
    $list


  Game.tick = (game) ->
    Game.update(game, game.tickLen)
    Game.draw(game)

  Game.draw = (game) ->
    switch game.playerInfos.length
      when 1
        Window.draw(game, game.tanks[0].pos, game.tanks[0],
          x: 0, y: 0, w: game.size.x, h: game.size.y, scale: 16)
      when 2
        Window.draw(game, game.tanks[0].pos, game.tanks[0],
          x: 0, y: 0, w: game.size.x / 2, h: game.size.y, scale: 14)
        Window.draw(game, game.tanks[1].pos, game.tanks[1],
          x: game.size.x / 2, y: 0, w: game.size.x / 2, h: game.size.y, scale: 14)
      when 3
        Window.draw(game, game.tanks[0].pos, game.tanks[0],
          x: 0, y: 0, w: game.size.x / 3, h: game.size.y, scale: 13)
        Window.draw(game, game.tanks[1].pos, game.tanks[1],
          x: game.size.x / 3, y: 0, w: game.size.x / 3, h: game.size.y, scale: 13)
        Window.draw(game, game.tanks[2].pos, game.tanks[2],
          x: 2 *game.size.x / 3, y: 0, w: game.size.x / 3, h: game.size.y, scale: 13)
      when 4
        Window.draw(game, game.tanks[0].pos, game.tanks[0],
          x: 0, y: 0, w: game.size.x / 2, h: game.size.y / 2, scale: 12)
        Window.draw(game, game.tanks[1].pos, game.tanks[1],
          x: game.size.x / 2, y: 0, w: game.size.x / 2, h: game.size.y / 2, scale: 12)
        Window.draw(game, game.tanks[2].pos, game.tanks[2],
          x: 0, y: game.size.y / 2, w: game.size.x / 2, h: game.size.y / 2, scale: 12)
        Window.draw(game, game.tanks[3].pos, game.tanks[3],
          x: game.size.x / 2, y: game.size.y / 2, w: game.size.x / 2, h: game.size.y / 2, scale: 12)
      else
        throw new Error("Unknown layout for given count of players")

  Game.update = (game, t) ->
    Game.updateBullets(game, t)
    Game.updateParticles(game, t)
    Game.updateBonuses(game, t)
    Game.updateTanks(game, t)

    game.time += t
    switch game.mode.mode
      when "time"
        if game.time > game.mode.time
          Game.finish(game)

  Game.updateTanks = (game, t) ->
    for i in [0...game.tanks.length] by 1
      game.tanks[i].update(game, t)

    for i in [0...game.tanks.length] by 1
      for j in [i+1...game.tanks.length] by 1
        Collisions.tankTank(game.tanks[i], game.tanks[j])

    for i in [0...game.tanks.length] by 1
      Collisions.tankMap(game.tanks[i], game.map)

    undefined

  Game.updateBullets = (game, t) ->
    Game.updateLive(game, game.bullets, (bullet) ->
      Collisions.bullet(bullet, game, t)
      bullet.move(t)
    )

  Game.updateParticles = (game, t) ->
    Game.updateLive(game, game.particles, (particle) ->
      particle.move(t)
    )

  Game.updateBonuses = (game, t) ->
    Game.updateLive(game, game.bonuses, (bonus) ->
      Collisions.bonus(bonus, game, t)
      bonus.update(t)
    )

  Game.updateLive = (game, objs, update) ->
    dead = 0
    for obj in objs
      unless obj.isDead
        update(obj)
      else
        dead = dead + 1

    if dead > objs.length * Game.MAX_GARBAGE_RATIO
      p = 0
      for i in [0...objs.length] by 1
        unless objs[i].isDead
          objs[p] = objs[i]
          p = p + 1
      objs.length = p

  Game
