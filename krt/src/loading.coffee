define ["jquery"], ($) ->
  Loading = {}

  Loading.SPINNER_FPS = 3
  Loading.SPINNER_SEQUENCE = "|/-\\"
  Loading.BITS_FPS = 10
  Loading.BITS_LENGTH = 80
  Loading.BITS_SYMS = 
    "0123456789qwertyuiopasdfghjklzxcvbnm,./;'[]<>?:\"{}`~!@#$%^&*()-=\\_+|"

  Loading.init = ($root) ->
    $main = $ """
      <div class='loading'>
        <p>Your browser is busy preparing the game for you. It has to download
        some files and generate the map. The algorithm requires a little noise,
        which takes some time to compute.</p>
        <div class='spinner'></div>
        <div class='bits'></div>
      </div>
      """
    $main.appendTo($root)

    loading = 
      $main: $main
      $root: $root
      spinnerTimer: undefined
      spinnerPos: 0
      bitsTimer: undefined

    loading.spinnerTimer = setInterval((-> Loading.spinnerTick(loading)), 1000 / Loading.SPINNER_FPS)
    loading.bitsTimer = setInterval((-> Loading.bitsTick(loading)), 1000 / Loading.BITS_FPS)

    Loading.spinnerTick(loading)
    Loading.bitsTick(loading)
    loading

  Loading.deinit = (loading) ->
    loading.$main.remove()
    clearInterval(loading.timer)

  Loading.spinnerTick = (loading) ->
    loading.spinnerPos = (loading.spinnerPos + 1) % Loading.SPINNER_SEQUENCE.length
    loading.$main.find(".spinner").text(Loading.SPINNER_SEQUENCE.charAt(loading.spinnerPos))

  Loading.bitsTick = (loading) ->
    sym = Loading.BITS_SYMS[Math.floor(Math.random() * Loading.BITS_SYMS.length)]
    loading.$main.find(".bits").append($("<span>").text(sym))

  Loading
