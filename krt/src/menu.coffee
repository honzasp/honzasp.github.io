define ["exports", "jquery", "game", "keycodes", "menu_players", "menu_config", "menu_credits", "menu_loading"],\
(exports, $, Game, Keycodes, MenuPlayers, MenuConfig, MenuCredits, MenuLoading) ->
  Menu = exports
  Menu.Players = MenuPlayers
  Menu.Config = MenuConfig
  Menu.Credits = MenuCredits
  Menu.Loading = MenuLoading

  Menu.COLORS = 
    "yellow": "#b38a0a"
    "orange": "#c7501e"
    "red": "#d73936"
    "magenta": "#cf3c83"
    "violet": "#6f73c1"
    "blue": "#2d8cce"
    "cyan": "#31a098"
    "green": "#86990a"
  Menu.KEYS = ["forward", "backward", "left", "right", "fire", "change"]
  Menu.MAX_PLAYERS = 4
  Menu.STATE_VERSION = 9

  Menu.DEFAULT_STATE = ->
    _version: Menu.STATE_VERSION
    mapWidth: 200
    mapHeight: 200
    mapNoisiness: 40
    mapEmptiness: 50
    mapSeed: ""
    playerCount: 2
    fps: 30
    hud: true
    nameTags: true
    audioEnabled: false
    soundsVolume: 100
    modes:
      mode: "time"
      time: 120
      lives: 10
      hits: 10
    playerDefs: [
      { name: "Oin", color: "red", \
        keys: { forward: 87, backward: 83, left: 65, right: 68, fire: 81, change: 69 } 
      }
      { name: "Gloin", color: "blue", \
        keys: { forward: 38, backward: 40, left: 37, right: 39, fire: 17, change: 16 } 
      }
      { name: "Bifur", color: "green", \
        keys: { forward: 73, backward: 75, left: 74, right: 76, fire: 85, change: 79 } 
      }
      { name: "Bombur", color: "cyan", \
        keys: { forward: 104, backward: 101, left: 100, right: 102, fire: 103, change: 105 }
      }
    ]

  Menu.USE_LOCAL_STORAGE = window.localStorage? and window.JSON?

  Menu.init = ($root) ->
    menu = 
      $root: $root
      $main: undefined
      game: undefined
      state: Menu.init.state()
    Menu.build(menu)
    menu

  if Menu.USE_LOCAL_STORAGE
    Menu.init.state = ->
      if jsonTxt = localStorage.getItem("krt settings")
        json = JSON.parse(jsonTxt)
        if json._version == Menu.STATE_VERSION
          return json
      Menu.DEFAULT_STATE()

    Menu.save = (menu) ->
      localStorage.setItem("krt settings", JSON.stringify(menu.state))
  else
    Menu.init.state = -> Menu.DEFAULT_STATE()
    Menu.save = (menu) ->

  Menu.build = (menu) ->
    menu.$main.remove() if menu.$main?
    menu.$main = $("<div class='menu'>").append [
      Menu.Config.buildConfig(menu)
      Menu.Players.buildPlayers(menu)
      Menu.buildStart(menu)
    ]

    menu.$main.appendTo(menu.$root)

  Menu.resetState = (menu) ->
    menu.state = Menu.DEFAULT_STATE()
    Menu.save(menu)
    Menu.build(menu)

  Menu.valInt = (elem, min = undefined, max = undefined) ->
    val = parseInt($(elem).val(), 10)
    return min if min? and val < min
    return max if max? and val > max
    val

  Menu.valFloat = (elem, min = undefined, max = undefined) ->
    val = parseFloat($(elem).val())
    return min if min? and val < min
    return max if max? and val > max
    val

  Menu.keyName = (keycode) ->
    Keycodes[keycode] || "key #{keycode}"

  Menu.selectKey = (menu, callback) ->
    $dialog = $ """
      <div class='dialog'>
        <div class='select-key'>
          <p>Press key</p>
          <p><input type='button' name='select-key-cancel' value='Cancel'></p>
        </div>
      </div>
      """

    $(document).one "keydown", (evt) ->
      $dialog.trigger("dismiss-select-key.krt")
      callback(evt.which)
      evt.preventDefault()
    $dialog.find("input[name=select-key-cancel]").click ->
      $dialog.trigger("dismiss-select-key.krt")
    $dialog.on "dismiss-select-key.krt", ->
      $dialog.remove()

    $dialog.appendTo(menu.$main)

  Menu.buildStart = (menu) ->
    $start = $ """
      <fieldset class='start'>
        <input type='button' name='start-button' value='start'>
        <input type='button' name='reset-button' value='reset settings'>
        <input type='button' name='credits-button' value='credits'>
      </fieldset>
      """
    $start.find("input[name=start-button]").click ->
      Menu.startGame(menu)
    $start.find("input[name=reset-button]").click ->
      Menu.resetState(menu)
    $start.find("input[name=credits-button]").click ->
      Menu.Credits.showCredits(menu)
    $start

  Menu.startGame = (menu) ->
    return if menu.game?

    state = menu.state
    settings =
      mapWidth: state.mapWidth
      mapHeight: state.mapHeight
      mapAmp: state.mapNoisiness / 100
      mapCaveLimit: Math.pow((state.mapEmptiness - 50)/50, 3)
      mapSeed: state.mapSeed || (new Date()).toString()
      startLives: state.modes.lives
      fps: state.fps
      useHud: state.hud
      useNameTags: state.nameTags
      enableAudio: state.audioEnabled
      soundsGain: state.soundsVolume / 100
      playerDefs: for i in [0...state.playerCount]
        name: state.playerDefs[i].name
        color: Menu.COLORS[state.playerDefs[i].color]
        keys: $.extend({}, state.playerDefs[i].keys)
      mode: switch state.modes.mode
        when "time"
          { mode: "time", time: state.modes.time }
        when "lives"
          { mode: "lives", lives: state.modes.lives }
        when "hits"
          { mode: "hits", hits: state.modes.hits }


    menu.$main.hide()
    loading = Menu.Loading.init(menu.$root)

    Game.init(settings,
      ((game) -> 
        menu.game = game
        Menu.Loading.deinit(loading)
        Game.start(game)),
      (->
        menu.game = undefined
        menu.$main.show())
    )

  Menu
