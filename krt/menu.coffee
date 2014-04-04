define ["jquery", "game"], ($, Game) ->
  Menu = {}

  Menu.init = ($root) ->
    menu =
      dom: Menu.init.prepareDom($root)
      game: undefined

    Menu.init.bindListeners(menu)
    menu

  Menu.init.prepareDom = ($root) ->
    $main = $("<div />").appendTo($root)
    $playBtn = $("<input type='button' value='Play' name='play'>").appendTo($main)
    $playerCountInp = $("<input type='text' value='2' name='player-count'>").appendTo($main)

    { $root, $main, $playBtn, $playerCountInp }

  Menu.init.bindListeners = (menu) ->
    menu.dom.$playBtn.click ->
      Menu.play(menu)

  Menu.play = (menu) ->
    playerCount = Math.floor(menu.dom.$playerCountInp.val() * 1)
    unless playerCount >= 1 and playerCount <= 4
      Menu.error("Please select one to four players")
      return

    settings = 
      fps: 30
      mapWidth: 100
      mapHeight: 50
      playerCount: playerCount

    if !menu.game?
      menu.game = Game.init(menu.dom.$root, settings)
      Game.start(menu.game)

  Menu
