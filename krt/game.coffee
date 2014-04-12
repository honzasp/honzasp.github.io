define \
["exports", "jquery", "map", "render", "tank", "bullet", "particle", "collisions", "update"], \
(exports, $, Map, Render, Tank, Bullet, Particle, Collisions, Update) ->

  Game = exports
  Game.MAX_GARBAGE_RATIO = 0.5

  Game.init = (settings, callback) ->
    map = Map.gen(settings)
    playerInfos = Game.init.createPlayers(settings, map)
    game = 
      dom: Game.init.prepareDom(game)
      map: map
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

  Game.init.createPlayers = (settings, map) ->
    for def, idx in settings.playerDefs
      index: idx, base: map.bases[idx],
      destroyed: 0, hits: 0,
      keys: def.keys, color: def.color

  Game.createTank = (game, playerInfo) ->
    {index: idx, base: {x, y}, color} = playerInfo
    new Tank(idx, x+Map.BASE_SIZE/2, y+Map.BASE_SIZE/2, 0, color)

  Game.deinit = (game) ->
    Game.stop(game)
    Game.unbindListeners(game)
    game.dom.$body.remove()
    game.dom.$oldBody.appendTo($("html"))
    game.callback()

  Game.tankDestroyed = (game, index, guilty = undefined) ->
    #game.tanks[index] = Game.createTank(game, game.playerInfos[index])
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

  Game.boom = (game, pos, spec) ->
    Update.boom(game, pos, spec)

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
    Render.game(game)

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
    Update.game(game, game.tickLen)
    Render.game(game)
    if game.mode.mode == "time" and game.time > game.mode.time
      Game.finish(game)

  Game
