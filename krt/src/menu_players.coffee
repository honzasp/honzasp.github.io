define ["jquery", "menu"], ($, Menu) ->
  Players = {}

  Players.buildPlayer = (menu, idx) ->
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
        Players.buildPlayerKey(menu, idx, key)
    )

    $player.on "changed-color.krt", ->
      colorName = $(@).find("option:selected").val()
      $player.css(borderLeftColor: Menu.COLORS[colorName])
      menu.state.playerDefs[idx].color = colorName
      Menu.save(menu)

    $player.trigger("changed-color")

  Players.buildPlayerKey = (menu, idx, key) ->
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

  Players.buildPlayers = (menu) ->
    $players = $ """
      <fieldset class='players'>
        <legend>players</legend>
        <p class='controls'>
          <input type='button' name='add-player' value='add player'>
          <input type='button' name='remove-player' value='remove player'>
        </p>
        <ul class='players-list'>
        </ul>
      </fieldset>
      """

    $players.find("input[name=add-player]").click ->
      if menu.state.playerCount < Menu.MAX_PLAYERS
        $players.find(".players-list").append(Players.buildPlayer(menu, menu.state.playerCount))
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
      $players.find(".players-list").append(Players.buildPlayer(menu, i))

    $players.trigger("changed-players.krt")
    $players

  Players
