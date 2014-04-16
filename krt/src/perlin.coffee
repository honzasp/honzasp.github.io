define [], () ->
  Perlin = {}

  Perlin.floatArray = if Float32Array?
      (n) -> new Float32Array(n)
    else
      (n) -> 0 for i in [0...n]

  Perlin.gen = (seed, width, height, opts) ->
    octaves = for i in [0...opts.octaves]
      w = Math.ceil(width * Math.pow(0.5, i)) + 1
      h = Math.ceil(height * Math.pow(0.5, i)) + 1
      Perlin.genOctave(seed + i, w, h)
    Perlin.composeOctaves(octaves, width, height, opts)

  Perlin.genOctave = (seed, width, height) ->
    array = Perlin.floatArray(width * height)
    add = (x, y, v) ->
      array[width*y + x] += v

    for x in [0...width] by 1
      add(x, 0, Perlin.noise(seed, x, 0))
      add(x, height-1, Perlin.noise(seed, x, height-1))

    for y in [1...height-1] by 1
      add(0, y, Perlin.noise(seed, 0, y))
      add(width-1, y, Perlin.noise(seed, width-1, y))

    for y in [1...height-1] by 1
      for x in [1...width-1] by 1
        v = Perlin.noise(seed, x, y)
        add(x, y, v/3)
        add(x-1, y, v/10)
        add(x+1, y, v/10)
        add(x, y-1, v/10)
        add(x, y+1, v/10)
        add(x-1, y-1, v/20)
        add(x-1, y+1, v/20)
        add(x+1, y-1, v/20)
        add(x+1, y+1, v/20)

    {array, width, height}

  Perlin.noise = (seed, x, y) ->
    x = ((x << 12) ^ x + seed)|0
    y = ((y << 14) ^ y + seed)|0
    a = ((x << 15) ^ y) ^ ((y << 12) ^ x)
    (((a * (((a * a)|0 * 2963)|0 + 4231)|0 + 4493)|0) & 0xfffffff) / 0x7ffffff - 1.0

  Perlin.composeOctaves = (octaves, width, height, opts) ->
    result = Perlin.floatArray(width * height)
    ampScale = (opts.amp - 1) / (Math.pow(opts.amp, octaves.length+1) - opts.amp)

    for i in [0...octaves.length] by 1
      octaveScale = Math.pow(0.5, i)
      amp = Math.pow(opts.amp, octaves.length - i)

      for y in [0...height] by 1
        for x in [0...width] by 1
          v = Perlin.interpolateOctave(octaves[i], x*octaveScale, y*octaveScale)
          result[y*width + x] += v * amp * ampScale

    {array: result, width, height}

  Perlin.interpolateOctave = (octave, x, y) ->
    xInt = Math.floor(x)
    yInt = Math.floor(y)
    xFrac = x - xInt
    yFrac = y - yInt

    f = (t) -> 6*Math.pow(t,5) - 15*Math.pow(t,4) + 10*Math.pow(t,3)
    interpolate = (a, b, d) -> a*(1-f(d)) + b*f(d)
    get = (x, y) ->
      throw new Error("index out of bounds") \
        unless x >= 0 and x < octave.width and y >= 0 and y < octave.height
      octave.array[y*octave.width + x]

    interpolate(
      interpolate(get(xInt, yInt), get(xInt, yInt+1), yFrac),
      interpolate(get(xInt+1, yInt), get(xInt+1, yInt+1), yFrac),
      xFrac
    )

  Perlin
