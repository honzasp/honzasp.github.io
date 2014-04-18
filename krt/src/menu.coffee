define ["jquery", "game", "keycodes"], ($, Game, Keycodes) ->
  Menu = {}

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
      Menu.buildMode(menu)
      Menu.buildMap(menu)
      Menu.buildGfx(menu)
      Menu.buildAudio(menu)
      Menu.buildPlayers(menu)
      Menu.buildStart(menu)
    ]

    menu.$main.on "game-loading.krt", ->
      menu.$main.find("input[name=start-button]").attr("disabled", true)
    menu.$main.on "game-finished.krt", ->
      menu.$main.find("input[name=start-button]").attr("disabled", false)

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

  Menu.buildMode = (menu) ->
    $mode = $ """
      <fieldset class='mode'>
        <legend>mode</legend>
        <p>
          <label><input type='radio' name='mode' value='time'> <span>time:</span></label>
          <input type='number' name='time' min='1' step='1' class='mode-depends mode-time'>
        </p>
        <p>
          <label><input type='radio' name='mode' value='lives'> <span>lives:</span></label>
          <input type='number' name='lives' min='1' step='1' class='mode-depends mode-lives'>
        </p>
        <p>
          <label><input type='radio' name='mode' value='hits'> <span>hits:</span></label>
          <input type='number' name='hits' min='1' step='1' class='mode-depends mode-hits'>
        </p>
      </fieldset>
      """
      
    $mode.find("input[name=time]").val(menu.state.modes.time).change ->
      menu.state.modes.time = valInt(@, 1); Menu.save(menu)
    $mode.find("input[name=lives]").val(menu.state.modes.lives).change ->
      menu.state.modes.lives = valInt(@, 1); Menu.save(menu)
    $mode.find("input[name=hits]").val(menu.state.modes.hits).change ->
      menu.state.modes.hits = valInt(@, 1); Menu.save(menu)

    $mode.find("input[name=mode]").change ->
      menu.state.modes.mode = $mode.find("input[name=mode]:checked").val()
      $mode.trigger("changed-mode.krt")
      Menu.save(menu)
    $mode.on "changed-mode.krt", ->
      $mode.find("input.mode-depends").attr("disabled", true)
      $mode.find("input.mode-#{menu.state.modes.mode}").removeAttr("disabled")

    $mode.find("input[name=mode][value=#{menu.state.modes.mode}]").attr("checked", true)
    $mode.trigger("changed-mode.krt")

    $mode

  Menu.buildMap = (menu) ->
    $map = $ """
      <fieldset class='map'>
        <legend>map</legend>
        <p>
          <label><span>width:</span> 
          <input type='number' name='map-width' min='50' step='1'></label>
        </p>
        <p>
          <label><span>height:</span> 
          <input type='number' name='map-height' min='50' step='1'></label>
        </p>
        <p>
          <label><span>noisiness:</span>
          <input type='number' name='map-noisiness' min='1' max='99'></label>
        </p>
        <p>
          <label><span>emptiness:</span> 
          <input type='number' name='map-emptiness' min='1' max='99'></label>
        </p>
        <p>
          <label><span>seed:</span>
          <input type='text' name='map-seed'></label>
        </p>
      </fieldset>
      """

    $map.find("input[name=map-width]").val(menu.state.mapWidth).change ->
      menu.state.mapWidth = valInt(@, 50); Menu.save(menu)
    $map.find("input[name=map-height]").val(menu.state.mapHeight).change ->
      menu.state.mapHeight = valInt(@, 50); Menu.save(menu)
    $map.find("input[name=map-noisiness]").val(menu.state.mapNoisiness).change ->
      menu.state.mapNoisiness = valFloat(@, 1, 99); Menu.save(menu)
    $map.find("input[name=map-emptiness]").val(menu.state.mapEmptiness).change ->
      menu.state.mapEmptiness = valFloat(@, 1, 99); Menu.save(menu)
    $map.find("input[name=map-seed]").val(menu.state.mapSeed).change ->
      menu.state.mapSeed = $(@).val(); Menu.save(menu)
    $map

  Menu.buildGfx = (menu) ->
    $gfx = $ """
      <fieldset class='gfx'>
        <legend>gfx</legend>
        <p>
          <label><span>frames per second:</span> 
          <input type='number' name='fps' value=''></label>
        </p>
        <p>
          <label><span>head-up display:</span>
          <input type='checkbox' name='hud'></label>
        </p>
        <p>
          <label><span>name tags:</span>
          <input type='checkbox' name='name-tags'></label>
        </p>
      </fieldset>
      """

    $gfx.find("input[name=fps]").val(menu.state.fps).change ->
      menu.state.fps = valFloat(@, 1, 200); Menu.save(menu)
    $gfx.find("input[name=hud]").attr("checked", menu.state.hud).change ->
      menu.state.hud = $(@).is(":checked"); Menu.save(menu)
    $gfx.find("input[name=name-tags]").attr("checked", menu.state.nameTags).change ->
      menu.state.nameTags = $(@).is(":checked"); Menu.save(menu)
    $gfx

  Menu.buildAudio = (menu) ->
    $audio = $ """
      <fieldset class='audio'>
        <legend>audio</legend>
        <p>
          <label><span>audio enabled:</span>
          <input type='checkbox' name='audio-enabled'></label>
        </p>
        <p>
          <label><span>sounds volume:</span>
          <input type='number' name='sounds-volume'></label>
        </p>
      </fieldset>
      """

    $audio.find("input[name=audio-enabled]").attr("checked", menu.state.audioEnabled).change ->
      menu.state.audioEnabled = $(@).is(":checked"); Menu.save(menu)
    $audio.find("input[name=sounds-volume]").val(menu.state.soundsVolume).change ->
      menu.state.soundsVolume = valFloat(@, 0, 100); Menu.save(menu)
    $audio

  Menu.buildPlayer = (menu, idx) ->
    $player = $ """
      <li class='player-#{idx}'>
        <p><label><span>name:</span> <input type='text' name='name-#{idx}' value=''></label></p>
        <p><label><span>color:</span> <select name='color-#{idx}'></select></label></p>
        <ul class='keys'>
        </ul>
      </li>
      """

    $player.find("input[name|=name]").val(menu.state.playerDefs[idx].name).change ->
      menu.state.playerDefs[idx].name = $(@).val(); Menu.save(menu)

    $player.find("select[name|=color]").append(
      for colorName of Menu.COLORS
        $("<option>").text(colorName).attr(
          value: colorName
          selected: colorName == menu.state.playerDefs[idx].color
        ).css(color: Menu.COLORS[colorName])
    ).change ->
      $player.trigger("changed-color.krt")

    $player.find(".keys").append(
      for key in Menu.KEYS
        Menu.buildPlayerKey(menu, idx, key)
    )

    $player.on "changed-color.krt", ->
      colorName = $(@).find("option:selected").val()
      $player.css(borderLeftColor: Menu.COLORS[colorName])
      menu.state.playerDefs[idx].color = colorName
      Menu.save(menu)

    $player.trigger("changed-color")

  Menu.buildPlayerKey = (menu, idx, key) ->
    $li = $ """
      <li><label><span>#{key}</span>
        <input type='button' name='key-#{key}-#{idx}' value=''>
      </label></li>
      """
    $li.find("input[name|=key]").val(Menu.keyName(menu.state.playerDefs[idx].keys[key])).click ->
      Menu.selectKey menu, (keycode) =>
        menu.state.playerDefs[idx].keys[key] = keycode
        $(@).val(Menu.keyName(keycode))
        Menu.save(menu)
    $li

  Menu.buildPlayers = (menu) ->
    $players = $ """
      <fieldset class='players'>
        <legend>players</legend>
        <p>
          <input type='button' name='add-player' value='add player'>
          <input type='button' name='remove-player' value='remove player'>
        </p>
        <ul class='players-list'>
        </ul>
      </fieldset>
      """

    $players.find("input[name=add-player]").click ->
      if menu.state.playerCount < Menu.MAX_PLAYERS
        $players.find(".players-list").append(Menu.buildPlayer(menu, menu.state.playerCount))
        menu.state.playerCount += 1
        $players.trigger("changed-players.krt")
        Menu.save(menu)

    $players.find("input[name=remove-player]").click ->
      if menu.state.playerCount > 0
        $players.find(".players-list>li:last-child").remove()
        menu.state.playerCount -= 1
        $players.trigger("changed-players.krt")
        Menu.save(menu)

    $players.on "changed-players.krt", ->
      $players.find("input[name=add-player]").attr("disabled", menu.state.playerCount >= Menu.MAX_PLAYERS)
      $players.find("input[name=remove-player]").attr("disabled", menu.state.playerCount <= 1)

    for i in [0...menu.state.playerCount]
      $players.find(".players-list").append(Menu.buildPlayer(menu, i))

    $players.trigger("changed-players.krt")
    $players

  Menu.buildStart = (menu) ->
    $start = $ """
      <fieldset class='start'>
        <input type='button' name='start-button' value='start'>
        <input type='button' name='reset-button' value='reset settings'>
      </fieldset>
      """
    $start.find("input[name=start-button]").click ->
      Menu.startGame(menu)
    $start.find("input[name=reset-button]").click ->
      Menu.resetState(menu)
    $start

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
        color: COLORS[state.playerDefs[i].color]
        keys: $.extend({}, state.playerDefs[i].keys)
      mode: switch state.modes.mode
        when "time"
          { mode: "time", time: state.modes.time }
        when "lives"
          { mode: "lives", lives: state.modes.lives }
        when "hits"
          { mode: "hits", hits: state.modes.hits }


    $menu.trigger("game-loading.krt")
    Game.init(settings,
      ((game) -> 
        menu.game = game
        Game.start(game)),
      (->
        menu.game = undefined
        $menu.trigger("game-finished.krt"))
    )

  Menu
