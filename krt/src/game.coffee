define \
["exports", "jquery", "map", "render", "tank", "bullet",
 "particle", "collisions", "update", "audio"], \
(exports, $, Map, Render, Tank, Bullet,
 Particle, Collisions, Update, Audio) ->

  Game = exports
  Game.MAX_GARBAGE_RATIO = 0.5

  Game.init = (settings, onReady, onFinish) ->
    map = audio = undefined
    mapReady = audioReady = false

    ready = ->
      return unless mapReady and audioReady

      playerInfos = for def, idx in settings.playerDefs
        index: idx, base: map.bases[idx],
        destroyed: 0, hits: 0,
        keys: def.keys, color: def.color, name: def.name

      game = 
        dom: Game.dom.init()
        audio: audio
        map: map
        tanks: Game.createTank(game, info) for info in playerInfos
        bullets: []
        particles: []
        bonuses: []
        time: 0
        size: {x: 800, y: 600}
        events: undefined
        tickLen: 1.0 / settings["fps"]
        timer: undefined
        playerInfos: playerInfos
        callback: onFinish
        mode: settings.mode
        useHud: settings.useHud
        useNameTags: settings.useNameTags
        onFinish: onFinish

      Game.dom.resizeCanvas(game)
      Game.dom.rebindListeners(game)
      onReady(game)

    Map.gen settings, (map_) -> map = map_; mapReady = true; ready()
    Audio.init settings, (audio_) -> audio = audio_; audioReady = true; ready()

    undefined

  Game.deinit = (game) ->
    Game.stop(game)
    Game.dom.unbindListeners(game)
    Game.dom.restore(game)
    game.callback()

  Game.createTank = (game, playerInfo) ->
    {index: idx, base: {x, y}, color} = playerInfo
    new Tank(idx, x+Map.BASE_SIZE/2, y+Map.BASE_SIZE/2, 0, color)

  Game.tankDestroyed = (game, index, guilty = undefined) ->
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

  Game.sound = (game, soundName, gain = 1.0) ->
    if game.audio?
      Audio.play(game.audio, soundName, gain)

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
      Game.dom.resizeCanvas(game)

  Game.start = (game) ->
    Game.stop(game) if game.timer?
    game.timer = setInterval((-> Game.tick(game)), game.tickLen * 1000)

  Game.stop = (game) ->
    clearInterval(game.timer) if game.timer?
    game.timer = undefined

  Game.pause = (game) ->
    Game.stop(game)
    Game.dom.unbindListeners(game)
    Game.dom.showPauseBox(game)

  Game.resume = (game) ->
    Game.dom.hidePauseBox(game)
    Game.dom.rebindListeners(game)
    Game.start(game)

  Game.finish = (game) ->
    Game.stop(game)
    Game.dom.showFinishBox(game)

  Game.tick = (game) ->
    Update.game(game, game.tickLen)
    Render.game(game)
    if game.mode.mode == "time" and game.time > game.mode.time
      Game.finish(game)

  Game.dom = {}
  Game.dom.init = ->
    $body = $("<body>").attr("id", "krt")
    $main = $("<div class='game'>").appendTo($body)
    $canvas = $("<canvas>").appendTo($main)
    $canvas.css
      "display": "block"
      "position": "fixed"
      "top": "0px"
      "left": "0px"
      "margin": "0px"
      "padding": "0px"
    ctx = $canvas[0].getContext("2d")

    $oldBody = $("body").detach()
    $("html").append($body)
    { $body, $oldBody, $main, $canvas, ctx, $pauseBox: undefined }

  Game.dom.restore = (game) ->
    game.dom.$body.remove()
    game.dom.$oldBody.appendTo($("html"))

  Game.dom.resizeCanvas = (game) ->
    game.size.x = window.innerWidth
    game.size.y = window.innerHeight
    game.dom.$canvas.attr("width", game.size.x)
    game.dom.$canvas.attr("height", game.size.y)
    Render.game(game)

  Game.dom.rebindListeners = (game) ->
    Game.dom.unbindListeners(game) if game.events?
    game.events = Game.events(game)
    $(window).on(game.events)

  Game.dom.unbindListeners = (game) ->
    return unless game.events?
    $(window).off(game.events)
    game.events = undefined

  Game.dom.showPauseBox = (game) ->
    Game.dom.hidePauseBox(game) if game.dom.$pauseBox?
    game.dom.$pauseBox = Game.dom.createPauseBox(game)
    game.dom.$main.append(game.dom.$pauseBox)

  Game.dom.hidePauseBox = (game) ->
    game.dom.$pauseBox.remove() if game.dom.$pauseBox?
    game.dom.$pauseBox = undefined

  Game.dom.createPauseBox = (game) ->
    $box = $ """
      <div class='pause-box box'>
        <div class='results'></div>

        <div class='controls'>
          <input type='button' name='resume' value='Resume'>
          <input type='button' name='quit' value='Quit'>
        </div>
      </div>
      """

    $box.find("input[name=resume]").click ->
      Game.resume(game)
    $box.find("input[name=quit]").attr("disabled", true).click ->
      Game.deinit(game)
    setTimeout((-> $box.find("input[name=quit]").attr("disabled", false)), 1500)

    $box.find(".results").append(Game.dom.createResults(game))
    $box

  Game.dom.showFinishBox = (game) ->
    Game.dom.hidePauseBox(game)
    unless game.dom.$finishBox?
      game.dom.$finishBox = Game.dom.createFinishBox(game)
      game.dom.$main.append(game.dom.$finishBox)


  Game.dom.createFinishBox = (game) ->
    $box = $ """
      <div class='finish-box box'>
        <div class='results'></div>

        <div class='controls'>
          <input type='button' name='ok' value='Ok'>
        </div>
      </div>
      """

    $box.find("input[name=ok]").attr("disabled", true).click ->
      Game.deinit(game)
    setTimeout((-> $box.find("input[name=ok]").attr("disabled", false)), 1500)

    $box.find(".results").append(Game.dom.createResults(game))
    $box

  Game.dom.createResults = (game) ->
    $table = $ """
      <table>
        <caption>results</caption>
        <thead><tr>
          <th class='name'>name</th>
          <th class='minus'>-</th>
          <th class='plus'>+</th>
          <th class='equals'>=</th>
        </tr></thead>
        <tbody></tbody>
      </table>
      """

    $table.find("tbody").append(for info in game.playerInfos
      $("<tr>").append \
        $("<td class='name'>").text(info.name).css(color: info.color),
        $("<td class='minus'>").text("-#{info.destroyed}"),
        $("<td class='plus'>").text("+#{info.hits}"),
        $("<td class='equals'>").text("#{info.hits - info.destroyed}")\
          .addClass(if info.hits > info.destroyed then "pos" else "neg")
    )

    $table

  Game
