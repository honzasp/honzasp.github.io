define ["jquery", "game", "keycodes"], ($, Game, Keycodes) ->
  COLORS = 
    "red": "#f00"
    "green": "#0f0"
    "blue": "#00f"
    "cyan": "#0ff"
  KEYS = ["forward", "backward", "left", "right", "fire", "change"]
  MAX_PLAYERS = 4
  STATE_VERSION = 2

  ($root) ->
    defaultState = ->
      _version: STATE_VERSION
      mapWidth: 100
      mapHeight: 50
      playerCount: 2
      fps: 30
      modes:
        mode: "time"
        time: 120
        lives: 10
        hits: 10
      playerDefs: [
        {
          name: "Oin"
          color: "red"
          keys: { forward: 87, backward: 83, left: 65, right: 68, fire: 81, change: 69 } 
        }
        {
          name: "Gloin"
          color: "blue"
          keys: { forward: 38, backward: 40, left: 37, right: 39, fire: 17, change: 16 } 
        }
        {
          name: "Bifur"
          color: "green"
          keys: { forward: 73, backward: 75, left: 74, right: 76, fire: 85, change: 79 } 
        }
        {
          name: "Bombur"
          color: "cyan"
          keys: { forward: 104, backward: 101, left: 100, right: 102, fire: 103, change: 105 }
        }
      ]

    if localStorage? and JSON?
      if jsonTxt = localStorage.getItem("krt settings")
        json = JSON.parse(jsonTxt)
        if json._version == STATE_VERSION
          state = json
      save = -> localStorage.setItem("krt settings", JSON.stringify(state))
    else
      save = ->

    state ||= defaultState()
    $menu = undefined

    resetState = ->
      state = defaultState()
      save()
      rebuild()

    rebuild = ->
      $menu.remove() if $menu?
      $menu = build()

    build = ->
      $("<div class='menu' />")\
        .append(buildMode())\
        .append(buildMap())\
        .append(buildFps())\
        .append(buildPlayers())\
        .append(buildStart())\
        .appendTo($root)

    buildMode = ->
      $mode = $ """
        <fieldset class='mode'>
          <legend>mode</legend>
          <p>
            <label><input type='radio' name='mode' value='time'> <span>time:</span></label>
            <input type='number' name='time' value='0' class='mode-depends mode-time'>
          </p>
          <p>
            <label><input type='radio' name='mode' value='lives'> <span>lives:</span></label>
            <input type='number' name='lives' value='0' class='mode-depends mode-lives'>
          </p>
          <p>
            <label><input type='radio' name='mode' value='hits'> <span>hits:</span></label>
            <input type='number' name='hits' value='0' class='mode-depends mode-hits'>
          </p>
        </fieldset>
        """
        
      $mode.find("input[name=time]").val(state.modes.time).change ->
        state.modes.time = $(@).val() * 1; save()
      $mode.find("input[name=lives]").val(state.modes.lives).change ->
        state.modes.lives = $(@).val() * 1; save()
      $mode.find("input[name=hits]").val(state.modes.hits).change ->
        state.modes.hits = $(@).val() * 1; save()

      $mode.find("input[name=mode]").change ->
        state.modes.mode = $mode.find("input[name=mode]:checked").val()
        $mode.trigger("changed-mode.krt")
        save()
      $mode.on "changed-mode.krt", ->
        $mode.find("input.mode-depends").attr("disabled", true)
        $mode.find("input.mode-#{state.modes.mode}").removeAttr("disabled")

      $mode.find("input[name=mode][value=#{state.modes.mode}]").attr("checked", true)
      $mode.trigger("changed-mode.krt")

      $mode

    buildMap = ->
      $map = $ """
        <fieldset class='map'>
          <legend>map</legend>
          <p>
            <label><span>width:</span> <input type='number' name='map-width' value=''></label>
          </p>
          <p>
            <label><span>height:</span> <input type='number' name='map-height' value=''></label>
          </p>
        </fieldset>
        """

      $map.find("input[name=map-width]").val(state.mapWidth).change ->
        state.mapWidth = $(@).val() * 1; save()
      $map.find("input[name=map-height]").val(state.mapHeight).change ->
        state.mapHeight = $(@).val() * 1; save()
      $map

    buildFps = ->
      $fps = $ """
        <fieldset class='fps'>
          <legend>fps</legend>
          <p><label><span>frames per second:</span> <input type='number' name='fps' value=''></label></p>
        </fieldset>
        """

      $fps.find("input[name=fps]").val(state.fps).change ->
        state.fps = $(@).val() * 1; save()
      $fps

    buildPlayer = (idx) ->
      $player = $ """
        <li class='player-#{idx}'>
          <p><label><span>name:</span> <input type='text' name='name-#{idx}' value=''></label></p>
          <p><label><span>color:</span> <select name='color-#{idx}'></select></label></p>
          <ul class='keys'>
          </ul>
        </li>
        """

      $player.find("input[name|=name]").val(state.playerDefs[idx].name).change ->
        state.playerDefs[idx].name = $(@).val(); save()

      $player.find("select[name|=color]").append(
        for colorName of COLORS
          $("<option>").text(colorName).attr(
            value: colorName
            selected: colorName == state.playerDefs[idx].color
          )
      ).change ->
        $player.trigger("changed-color.krt")

      $player.find(".keys").append(
        for key in KEYS
          buildPlayerKey(idx, key)
      )

      $player.on "changed-color.krt", ->
        colorName = $(@).find("option:selected").val()
        $player.css(borderLeftColor: COLORS[colorName])
        state.playerDefs[idx].color = colorName
        save()

      $player.trigger("changed-color")

    buildPlayerKey = (idx, key) ->
      $li = $ """
        <li><label><span>#{key}</span>
          <input type='button' name='key-#{key}-#{idx}' value=''>
        </label></li>
        """
      $li.find("input[name|=key]").val(keyName(state.playerDefs[idx].keys[key])).click ->
        selectKey (keycode) =>
          state.playerDefs[idx].keys[key] = keycode
          $(@).val(keyName(keycode))
          save()
      $li

    buildPlayers = ->
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
        if state.playerCount < MAX_PLAYERS
          $players.find(".players-list").append(buildPlayer(state.playerCount))
          state.playerCount += 1
          $players.trigger("changed-players.krt")
          save()

      $players.find("input[name=remove-player]").click ->
        if state.playerCount > 0
          $players.find(".players-list>li:last-child").remove()
          state.playerCount -= 1
          $players.trigger("changed-players.krt")
          save()

      $players.on "changed-players.krt", ->
        $players.find("input[name=add-player]").attr("disabled", state.playerCount >= MAX_PLAYERS)
        $players.find("input[name=remove-player]").attr("disabled", state.playerCount <= 0)

      for i in [0...state.playerCount]
        $players.find(".players-list").append(buildPlayer(i))

      $players

    buildStart = ->
      $start = $ """
        <fieldset class='start'>
          <input type='button' name='start-button' value='start'>
          <input type='button' name='reset-button' value='reset settings'>
        </fieldset>
        """
      $start.find("input[name=start-button]").click ->
        startGame()
      $start.find("input[name=reset-button]").click ->
        resetState()
      $start

    keyName = (keycode) ->
      Keycodes[keycode] || "key #{keycode}"

    selectKey = (callback) ->
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

      $dialog.appendTo($menu)

    startGame = ->
      settings =
        mapWidth: state.mapWidth
        mapHeight: state.mapHeight
        startLives: state.modes.lives
        fps: state.fps
        playerDefs: for i in [0...state.playerCount]
          name: state.playerDefs[i].name
          color: state.playerDefs[i].color
          keys: $.extend({}, state.playerDefs[i].keys)
        mode: switch state.modes.mode
          when "time"
            { mode: "time", time: state.modes.time }
          when "lives"
            { mode: "lives", lives: state.modes.lives }
          when "hits"
            { mode: "hits", hits: state.modes.hits }


      game = Game.init(settings, ->)
      Game.start(game)

    $menu = build()
