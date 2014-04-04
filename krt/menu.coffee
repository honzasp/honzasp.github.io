define ["jquery", "game"], ($, Game) ->
  class Menu
    constructor: (@$root) ->
      @$menu = $("<div></div>").appendTo(@$root)
      @$playBtn = $("<button>Play</button>").appendTo(@$menu)

      @$playBtn.click => @play()

    play: ->
      settings = 
        "fps": 30
        "map width": 100
        "map height": 50

      if !@game?
        @game = Game.init(@$root, settings)
        Game.start(@game)
