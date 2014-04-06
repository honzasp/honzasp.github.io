define ["exports", "jquery", "map", "window", "tank", "bullet", "particle", "collisions"], \
(exports, $, Map, Window, Tank, Bullet, Particle, Collisions) ->
  Game = exports
  Game.MAX_GARBAGE_RATIO = 0.5
  Game.BASE_SIZE = 8
  Game.BASE_DOOR_SIZE = 2

  Game.init = ($root, settings, callback) ->
    playerInfos = Game.init.createPlayers(settings)
    game = 
      dom: Game.init.prepareDom($root)
      map: Game.init.createMap(settings, playerInfos)
      tanks: Game.createTank(game, info) for info in playerInfos
      bullets: []
      particles: []
      size: {x: 800, y: 600}
      events: undefined
      tickLen: 1.0 / settings["fps"]
      timer: undefined
      playerInfos: playerInfos
      callback: callback

    Game.resizeCanvas(game)
    Game.rebindListeners(game)
    game

  Game.init.prepareDom = ($root) ->
    $main = $("<div />").appendTo($root)
    $canvas = $("<canvas />").appendTo($main)
    $canvas.css
      "display": "block"
      "position": "absolute"
      "top": "0px"
      "left": "0px"
      "margin": "0px"
      "padding": "0px"

    ctx = $canvas[0].getContext("2d")
    { $root, $main, $canvas, ctx}

  Game.init.createPlayers = (settings) ->
    for i in [0...settings.playerCount]
      x = Math.floor(Math.random() * (settings.mapWidth - Game.BASE_SIZE))
      y = Math.floor(Math.random() * (settings.mapHeight - Game.BASE_SIZE))
      {index: i, base: {x, y}, lives: settings.startLives, hits: 0}

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
    {index: idx, base: {x, y}} = playerInfo
    new Tank(idx, x+Game.BASE_SIZE/2, y+Game.BASE_SIZE/2)

  Game.deinit = (game) ->
    Game.stop(game)
    Game.unbindListeners(game)
    game.dom.$main.remove()
    game.callback()

  Game.tankDestroyed = (game, index, guilty = undefined) ->
    game.tanks[index] = Game.createTank(game, game.playerInfos[index])
    game.playerInfos[guilty].hits += 1 if guilty?
    game.playerInfos[index].lives -= 1
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
    keydown: (evt) ->
      switch evt.which
        when 87 # w
          game.tanks[0].acc = 1
        when 83 # s
          game.tanks[0].acc = -1
        when 65 # a
          game.tanks[0].rot = 1
        when 68 # d
          game.tanks[0].rot = -1
        when 81 # q
          game.tanks[0].fire(game)

    keyup: (evt) ->
      switch evt.which
        when 87 # w
          game.tanks[0].acc = 0 if game.tanks[0].acc > 0
        when 83 # s
          game.tanks[0].acc = 0 if game.tanks[0].acc < 0
        when 65 # a
          game.tanks[0].rot = 0 if game.tanks[0].rot > 0
        when 68 # d
          game.tanks[0].rot = 0 if game.tanks[0].rot < 0

    resize: (evt) ->
      Game.resizeCanvas(game)

  Game.resizeCanvas = (game) ->
    game.size.x = window.innerWidth
    game.size.y = window.innerHeight
    game.dom.$canvas.attr("width", game.size.x)
    game.dom.$canvas.attr("height", game.size.y)

  Game.start = (game) ->
    Game.stop(game) if game.timer?
    game.timer = setInterval((-> Game.tick(game)), game.tickLen * 1000)

  Game.stop = (game) ->
    clearInterval(game.timer) if game.timer?
    game.timer = undefined

  Game.finish = (game) ->
    Game.deinit(game)

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
    Game.updateTanks(game, t)

  Game.updateTanks = (game, t) ->
    for i in [0...game.tanks.length]
      game.tanks[i].move(t)

    for i in [0...game.tanks.length]
      for j in [i+1...game.tanks.length]
        Collisions.tankTank(game.tanks[i], game.tanks[j])

    for i in [0...game.tanks.length]
      Collisions.tankMap(game.tanks[i], game.map)

    undefined

  Game.updateBullets = (game, t) ->
    Game.updateLiving(game, game.bullets, (bullet) ->
      Collisions.bullet(bullet, game, t)
      bullet.move(t)
    )

  Game.updateParticles = (game, t) ->
    Game.updateLiving(game, game.particles, (particle) ->
      particle.move(t)
    )

  Game.updateLiving = (game, objs, update) ->
    dead = 0
    for i in [0...objs.length]
      unless objs[i].isDead
        update(objs[i])
      else
        dead = dead + 1

    if dead > objs.length * Game.MAX_GARBAGE_RATIO
      p = 0
      for i in [0...objs.length]
        unless objs[i].isDead
          objs[p] = objs[i]
          p = p + 1
      objs.length = p

  Game
