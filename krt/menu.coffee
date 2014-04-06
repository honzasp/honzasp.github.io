define ["jquery", "game"], ($, Game) ->
  Menu = {}

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
      playerCount: playerCount
      startLives: startLives

    if !menu.game?
      Menu.hide(menu)
      menu.game = Game.init(menu.dom.$root, settings, ->
        Menu.show(menu)
        menu.game = undefined
      )
      Game.start(menu.game)

  Menu
