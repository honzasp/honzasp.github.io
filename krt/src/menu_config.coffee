define ["menu"], (Menu) ->
  Config = {}

  Config.buildConfig = (menu) ->
    $config = $ """
      <div class='config'>
        <div class='left'></div>
        <div class='right'></div>
      </div>
      """

    $config.find(".left").append [
      Config.buildMode(menu)
      Config.buildMap(menu)
    ]

    $config.find(".right").append [
      Config.buildGfx(menu)
      Config.buildAudio(menu)
    ]

    $config

  Config.buildMode = (menu) ->
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
      menu.state.modes.time = Menu.valInt(@, 1); Menu.save(menu)
    $mode.find("input[name=lives]").val(menu.state.modes.lives).change ->
      menu.state.modes.lives = Menu.valInt(@, 1); Menu.save(menu)
    $mode.find("input[name=hits]").val(menu.state.modes.hits).change ->
      menu.state.modes.hits = Menu.valInt(@, 1); Menu.save(menu)

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

  Config.buildMap = (menu) ->
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
      menu.state.mapWidth = Menu.valInt(@, 50); Menu.save(menu)
    $map.find("input[name=map-height]").val(menu.state.mapHeight).change ->
      menu.state.mapHeight = Menu.valInt(@, 50); Menu.save(menu)
    $map.find("input[name=map-noisiness]").val(menu.state.mapNoisiness).change ->
      menu.state.mapNoisiness = Menu.valFloat(@, 1, 99); Menu.save(menu)
    $map.find("input[name=map-emptiness]").val(menu.state.mapEmptiness).change ->
      menu.state.mapEmptiness = Menu.valFloat(@, 1, 99); Menu.save(menu)
    $map.find("input[name=map-seed]").val(menu.state.mapSeed).change ->
      menu.state.mapSeed = $(@).val(); Menu.save(menu)
    $map

  Config.buildGfx = (menu) ->
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
      menu.state.fps = Menu.valFloat(@, 1, 200); Menu.save(menu)
    $gfx.find("input[name=hud]").attr("checked", menu.state.hud).change ->
      menu.state.hud = $(@).is(":checked"); Menu.save(menu)
    $gfx.find("input[name=name-tags]").attr("checked", menu.state.nameTags).change ->
      menu.state.nameTags = $(@).is(":checked"); Menu.save(menu)
    $gfx

  Config.buildAudio = (menu) ->
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
      $audio.trigger("audio-changed.krt")
    $audio.find("input[name=sounds-volume]").val(menu.state.soundsVolume).change ->
      menu.state.soundsVolume = Menu.valFloat(@, 0, 100); Menu.save(menu)

    $audio.on "audio-changed.krt", ->
      $audio.find("input[name=sounds-volume]").attr("disabled", !menu.state.audioEnabled)

    $audio.trigger("audio-changed.krt")
    $audio

  Config
