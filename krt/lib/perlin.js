// Generated by CoffeeScript 1.6.3
(function() {
  define([], function() {
    var Perlin;
    Perlin = {};
    Perlin.floatArray = typeof Float32Array !== "undefined" && Float32Array !== null ? function(n) {
      return new Float32Array(n);
    } : function(n) {
      var i, _i, _results;
      _results = [];
      for (i = _i = 0; 0 <= n ? _i < n : _i > n; i = 0 <= n ? ++_i : --_i) {
        _results.push(0);
      }
      return _results;
    };
    Perlin.gen = function(seed, width, height, opts) {
      var h, i, octaves, w;
      octaves = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = opts.octaves; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          w = Math.ceil(width * Math.pow(0.5, i)) + 1;
          h = Math.ceil(height * Math.pow(0.5, i)) + 1;
          _results.push(Perlin.genOctave(seed + i, w, h));
        }
        return _results;
      })();
      return Perlin.composeOctaves(octaves, width, height, opts);
    };
    Perlin.genOctave = function(seed, width, height) {
      var add, array, v, x, y, _i, _j, _k, _l, _ref, _ref1, _ref2;
      array = Perlin.floatArray(width * height);
      add = function(x, y, v) {
        return array[width * y + x] += v;
      };
      for (x = _i = 0; _i < width; x = _i += 1) {
        add(x, 0, Perlin.noise(seed, x, 0));
        add(x, height - 1, Perlin.noise(seed, x, height - 1));
      }
      for (y = _j = 1, _ref = height - 1; _j < _ref; y = _j += 1) {
        add(0, y, Perlin.noise(seed, 0, y));
        add(width - 1, y, Perlin.noise(seed, width - 1, y));
      }
      for (y = _k = 1, _ref1 = height - 1; _k < _ref1; y = _k += 1) {
        for (x = _l = 1, _ref2 = width - 1; _l < _ref2; x = _l += 1) {
          v = Perlin.noise(seed, x, y);
          add(x, y, v / 3);
          add(x - 1, y, v / 10);
          add(x + 1, y, v / 10);
          add(x, y - 1, v / 10);
          add(x, y + 1, v / 10);
          add(x - 1, y - 1, v / 20);
          add(x - 1, y + 1, v / 20);
          add(x + 1, y - 1, v / 20);
          add(x + 1, y + 1, v / 20);
        }
      }
      return {
        array: array,
        width: width,
        height: height
      };
    };
    Perlin.noise = function(seed, x, y) {
      var a;
      x = ((x << 12) ^ x + seed) | 0;
      y = ((y << 14) ^ y + seed) | 0;
      a = ((x << 15) ^ y) ^ ((y << 12) ^ x);
      return (((a * (((a * a) | 0 * 2963) | 0 + 4231) | 0 + 4493) | 0) & 0xfffffff) / 0x7ffffff - 1.0;
    };
    Perlin.composeOctaves = function(octaves, width, height, opts) {
      var amp, ampScale, i, octaveScale, result, v, x, y, _i, _j, _k, _ref;
      result = Perlin.floatArray(width * height);
      ampScale = (opts.amp - 1) / (Math.pow(opts.amp, octaves.length + 1) - opts.amp);
      for (i = _i = 0, _ref = octaves.length; _i < _ref; i = _i += 1) {
        octaveScale = Math.pow(0.5, i);
        amp = Math.pow(opts.amp, octaves.length - i);
        for (y = _j = 0; _j < height; y = _j += 1) {
          for (x = _k = 0; _k < width; x = _k += 1) {
            v = Perlin.interpolateOctave(octaves[i], x * octaveScale, y * octaveScale);
            result[y * width + x] += v * amp * ampScale;
          }
        }
      }
      return {
        array: result,
        width: width,
        height: height
      };
    };
    Perlin.interpolateOctave = function(octave, x, y) {
      var f, get, interpolate, xFrac, xInt, yFrac, yInt;
      xInt = Math.floor(x);
      yInt = Math.floor(y);
      xFrac = x - xInt;
      yFrac = y - yInt;
      f = function(t) {
        return 6 * Math.pow(t, 5) - 15 * Math.pow(t, 4) + 10 * Math.pow(t, 3);
      };
      interpolate = function(a, b, d) {
        return a * (1 - f(d)) + b * f(d);
      };
      get = function(x, y) {
        if (!(x >= 0 && x < octave.width && y >= 0 && y < octave.height)) {
          throw new Error("index out of bounds");
        }
        return octave.array[y * octave.width + x];
      };
      return interpolate(interpolate(get(xInt, yInt), get(xInt, yInt + 1), yFrac), interpolate(get(xInt + 1, yInt), get(xInt + 1, yInt + 1), yFrac), xFrac);
    };
    return Perlin;
  });

}).call(this);
