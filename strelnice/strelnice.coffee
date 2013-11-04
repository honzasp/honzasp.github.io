$ ->
  Game =
    running: false
    screen: $ "#screen"
    infoBox: $ "#info-box"
    ballCanvas: $ "#ball"
    resultBox: $ "#result-box"

    ballColor: "#000"
    backgroundColor: "#57c889"

    start: ({time, size, button}) ->
      unless @running
        @time = time
        @ballSize = size
        @button = button

        @prepareBall()
        @prepareScreen()

        @hitCount = 0
        @missCount = 0
        @placeBall()
        @updateInfo()
        setTimeout((=> @timeOut()), @time * 1000)

        @running = true

    prepareBall: ->
      @ballCanvas.attr "width", @ballSize
      @ballCanvas.attr "height", @ballSize
      @ballCanvas.css "position", "absolute"

      ctx = @ballCanvas[0].getContext "2d"
      ctx.beginPath()
      ctx.arc(@ballSize/2, @ballSize/2, @ballSize/2, 0, 2*Math.PI)
      ctx.fillStyle = @ballColor
      ctx.fill()

      @ballCanvas.show()

    prepareScreen: ->
      @screen.css
        "background-color": @backgroundColor
      @screen.show()
      @resizeScreen()

      # hide the banner
      $("body div[style*='!important']").remove()

    resizeScreen: ->
      @screenWidth = $(window).width()
      @screenHeight = $(window).height()

      @screen.css
        "width": "#{@screenWidth}px"
        "height": "#{@screenHeight}px"

    updateInfo: ->
      $(".hits", @infoBox).text("#{@hitCount}")
      $(".miss", @infoBox).text("#{@missCount}")

    click: (x, y, button) ->
      if @running
        relX = x - @ballX
        relY = y - @ballY
        distSq = relX * relX + relY * relY

        if distSq <= (@ballSize*@ballSize)/4 and @button == button
          @hitCount += 1
        else
          @missCount += 1
          @showMiss()

        @placeBall()
        @updateInfo()
        true
      else
        false

    showMiss: ->
      @screen.css "background-color", "#555"
      setTimeout((=> @screen.css "background-color", @backgroundColor), 100)

    placeBall: ->
      cornerX = Math.random() * (@screenWidth - @ballSize)
      cornerY = Math.random() * (@screenHeight - @ballSize)

      @ballCanvas.css
        "left": "#{cornerX}px"
        "top": "#{cornerY}px"
      @ballX = cornerX + @ballSize / 2
      @ballY = cornerY + @ballSize / 2

    timeOut: ->
      @stop()

    stop: ->
      if @running
        $(".time", @resultBox).text("#{@time}")
        $(".hits", @resultBox).text("#{@hitCount}")
        $(".miss", @resultBox).text("#{@missCount}")
        $(".hits_per_min", @resultBox).text("#{Math.round(@hitCount / @time * 60)}")

        @resultBox.one "click", =>
          @hide()

        @resultBox.show()
        @running = false

    hide: ->
      @screen.hide()
      @resultBox.hide()

  Game.hide()

  $(window).resize -> Game.resizeScreen()

  $(window).mousedown (evt) ->
    [x, y] = [evt.pageX, evt.pageY]
    button = switch evt.which
      when 1 then "left"
      when 2 then "middle"
      when 3 then "right"

    if button? && Game.click(x, y, button)
      evt.preventDefault()

  $(window).bind "contextmenu", (evt) ->
    if Game.running
      evt.preventDefault()

  $(window).keydown (evt) ->
    if evt.which == 27
      Game.stop()

  $("#in-start").click ->
    time = $("#in-time").val() * 1
    size = $("#in-size").val() * 1
    button = $("input[name=in-button]:checked").val()

    Game.start {time, size, button}
