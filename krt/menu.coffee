define ["jquery", "game"], ($, Game) ->
  Menu = {}

  Menu.PLAYER_DEFS = [
    { keys: { forward: 87, backward: 83, left: 65, right: 68, fire: 81 } }
    { keys: { forward: 38, backward: 40, left: 37, right: 39, fire: 17 } }
    { keys: { forward: 73, backward: 75, left: 74, right: 76, fire: 85 } }
    { keys: { forward: 104, backward: 101, left: 100, right: 102, fire: 103 } }
  ]

  Menu.init = ($root) ->
    menu =
      dom: Menu.init.prepareDom($root)
      game: undefined

    Menu.init.bindListeners(menu)
    Menu.show(menu)
    menu

  Menu.init.prepareDom = ($root) ->
    $main = $("<div />").appendTo($root)
    $playBtn = $("<input type='button' value='Play' name='play'>").appendTo($main)
    $playerCountInp = $("<input type='text' value='2' name='player-count'>").appendTo($main)
    $startLivesInp = $("<input type='text' value='10' name='start-lives'>").appendTo($main)
    $errorBox = $("<p class='error'></p>").appendTo($main)
    $errorBox.hide()

    { $root, $main, $playBtn, $playerCountInp, $startLivesInp }

  Menu.init.bindListeners = (menu) ->
    menu.dom.$playBtn.click ->
      Menu.play(menu)

  Menu.error = (menu, msg) ->
    menu.dom.$errorBox.text(msg)
    menu.dom.$errorBox.show()

  Menu.show = (menu) ->
    menu.dom.$main.show()

  Menu.hide = (menu) ->
    menu.dom.$main.hide()

  Menu.play = (menu) ->
    playerCount = Math.floor(menu.dom.$playerCountInp.val() * 1)
    unless playerCount >= 1 and playerCount <= 4
      Menu.error(menu, "Please select one to four players")
      return

    startLives = Math.floor(menu.dom.$startLivesInp.val() * 1)
    unless startLives > 0
      Menu.error(menu, "Please set positive number of lives")
      return

    settings = 
      fps: 30
      mapWidth: 100
      mapHeight: 50
      playerDefs: Menu.PLAYER_DEFS[0...playerCount]
      startLives: startLives

    if !menu.game?
      Menu.hide(menu)
      menu.game = Game.init(menu.dom.$root, settings, ->
        Menu.show(menu)
        menu.game = undefined
      )
      Game.start(menu.game)

  Menu
