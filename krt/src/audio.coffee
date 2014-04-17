define ["require"], (require) ->
  Audio = {}

  Audio.SOUNDS_URL = require.toUrl("../sound")
  Audio.SOUNDS = {
    "boom_autocannon": ["boom_autocannon_1.wav"]
    "boom_huge_cannon": ["boom_huge_cannon_1.wav"]
    "boom_mining_gun": ["boom_mining_gun_1.wav"]
    "boom_tank": ["boom_tank_1.wav"]
    "get_energy": ["get_energy_1.wav"]
    "get_mass": ["get_mass_1.wav"]
    "hit_concrete": ["hit_concrete_1.wav", "hit_concrete_2.wav"]
    "hit_metal": ["hit_metal_1.wav", "hit_metal_2.wav"]
    "hit_rock": ["hit_rock_1.wav", "hit_rock_2.wav"]
    "hit_tank": ["hit_tank_1.wav"]
    "hum_tank": ["hum_tank_1.wav"]
    "shoot_autocannon": ["shoot_autocannon_1.wav"]
    "shoot_emergency_gun": ["shoot_emergency_gun_1.wav"]
    "shoot_huge_cannon": ["shoot_huge_cannon_1.wav"]
    "shoot_machine_gun": ["shoot_machine_gun_1.wav"]
    "shoot_mining_gun": ["shoot_mining_gun_1.wav"]
  }
  Audio.LOAD_TIMEOUT = 20

  Audio.supported = ->
    window.AudioContext? or window.webkitAudioContext?

  Audio.init = (settings, callback) ->
    if settings.enableAudio and Audio.supported()
      ctx = new (window.AudioContext or window.webkitAudioContext)()
      buffers = {}
      callbackCalled = false

      ready = ->
        return if callbackCalled
        for soundName, soundFiles of Audio.SOUNDS
          return unless buffers[soundName].length >= soundFiles.length

        callbackCalled = true
        callback({ ctx, buffers })

      error = (err) ->
        console.log("error initializing audio", err)
        unless callbackCalled
          callbackCalled = true
          callback(undefined)

      timeout = ->
        error("timeout") unless callbackCalled

      setTimeout(timeout, Audio.LOAD_TIMEOUT * 1000)

      for soundName of Audio.SOUNDS
        buffers[soundName] = []
        for soundFile in Audio.SOUNDS[soundName]
          do (soundName, soundFile) ->
            onLoaded = (buf) -> buffers[soundName].push(buf); ready()
            onError = (err) -> error(err)
            url = "#{Audio.SOUNDS_URL}/#{soundFile}"
            Audio.init.loadSound(ctx, url, onLoaded, onError)

    else
      callback(undefined)
    undefined

  Audio.init.loadSound = (ctx, url, onLoaded, onError) ->
    req = new XMLHttpRequest()
    req.open("GET", url, true)
    req.responseType = "arraybuffer"
    req.onload = -> ctx.decodeAudioData(req.response, onLoaded, onError)
    req.onerror = onError
    req.send()

  Audio.soundSource = (audio, soundName) ->
    buffers = audio.buffers[soundName]
    buffer = buffers[Math.floor(Math.random() * buffers.length)]
    sourceNode = audio.ctx.createBufferSource()
    sourceNode.buffer = buffer
    sourceNode

  Audio.addGain = (audio, node) ->
    gainNode = audio.ctx.createGainNode()
    node.connect(gainNode)
    gainNode

  Audio.play = (audio, soundName, gain) ->
    sourceNode = Audio.soundSource(audio, soundName)
    gainNode = Audio.addGain(audio, sourceNode)
    gainNode.gain.value = gain
    gainNode.connect(audio.ctx.destination)
    sourceNode.start(0)

  Audio
