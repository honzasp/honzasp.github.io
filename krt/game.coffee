define ["jquery", "map", "window", "tank", "bullet", "collisions"], \
($, Map, Window, Tank, Bullet, Collisions) ->
  Game = {}
  Game.MAX_GARBAGE_RATIO = 0.5

  Game.init = ($root, settings) ->
    game = 
      dom: Game.init.prepareDom($root)
      map: Game.init.createMap(settings)
      tanks: Game.init.createTanks(settings)
      bullets: []
      size: {x: 800, y: 600}
      events: undefined
      tickLen: 1.0 / settings["fps"]
      timer: undefined

    Game.resizeCanvas(game)
    Game.rebindListeners(game)
    game

  Game.init.prepareDom = ($root) ->
    $main = $("<div />").appendTo($root)
    $canvas = $("<canvas />").appendTo($main)
    ctx = $canvas[0].getContext("2d")
    { $root, $main, $canvas, ctx}

  Game.init.createMap = (settings) ->
    map = Map.init(settings["map width"], settings["map height"])
    for y in [2..20]
      for x in [3..13]
        Map.set(map, x, y, Map.ROCK)
    Map.set(map, 4, 3, Map.STEEL)
    map

  Game.init.createTanks = (settings) ->
    [Tank.init(1.8, 2.0), Tank.init(3.0, 1.2)]

  Game.rebindListeners = (game) ->
    Game.unbindListeners(game) if game.events?
    game.events = Game.events(game)
    $(document).on("keydown", game.events.keydown)
    $(document).on("keyup", game.events.keyup)

  Game.unbindListeners = (game) ->
    return unless game.events?
    $(document).off("keydown", game.events.keydown)
    $(document).off("keyup", game.events.keyup)
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
          Tank.fire(game.tanks[0], game)

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

  Game.resizeCanvas = (game) ->
    game.dom.$canvas.attr("width", game.size.x)
    game.dom.$canvas.attr("height", game.size.y)

  Game.start = (game) ->
    Game.stop(game) if game.timer?
    game.timer = setInterval((-> Game.tick(game)), game.tickLen * 1000)

  Game.stop = (game) ->
    clearInterval(game.timer) if game.timer?
    game.timer = undefined

  Game.tick = (game) ->
    Game.update(game, game.tickLen)
    Game.draw(game)

  Game.draw = (game) ->
    Window.draw(game, game.tanks[0].pos, x: 0, y: 0, w: game.size.x, h: game.size.y, scale: 16)

  Game.update = (game, t) ->
    Game.updateTanks(game, t)
    Game.updateBullets(game, t)

  Game.updateTanks = (game, t) ->
    for i in [0...game.tanks.length]
      Tank.move(game.tanks[i], t)

    for i in [0...game.tanks.length]
      for j in [i+1...game.tanks.length]
        Collisions.tankTank(game.tanks[i], game.tanks[j])

    for i in [0...game.tanks.length]
      Collisions.tankMap(game.tanks[i], game.map)

    undefined

  Game.updateBullets = (game, t) ->
    bullets = game.bullets
    dead = 0
    for i in [0...bullets.length]
      unless bullets[i].isDead
        Collisions.bullet(bullets[i], t, game.map, game.tanks)
        Bullet.move(bullets[i], t)
      else
        dead = dead + 1

    if dead > bullets.length * Game.MAX_GARBAGE_RATIO
      p = 0
      for i in [0...bullets.length]
        unless bullets[i].isDead
          bullets[p] = bullets[i]
          p = p + 1
      bullets.length = p

  Game
