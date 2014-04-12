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
          w = Math.floor(width * Math.pow(0.5, i));
          h = Math.floor(height * Math.pow(0.5, i));
          _results.push(Perlin.genOctave(seed + i, w, h));
        }
        return _results;
      })();
      return Perlin.composeOctaves(octaves, opts);
    };
    Perlin.genOctave = function(seed, width, height) {
      var add, array, v, x, y, _i, _j, _k, _ref, _ref1;
      array = Perlin.floatArray(width * height);
      add = function(x, y, v) {
        return array[width * y + x] += v;
      };
      for (x = _i = 0; _i < width; x = _i += 1) {
        add(x, 0, Perlin.noise(seed, x, 0));
        add(x, height - 1, Perlin.noise(seed, x, height - 1));
      }
      for (y = _j = 1, _ref = height - 1; _j < _ref; y = _j += 1) {
        for (x = _k = 1, _ref1 = width - 1; _k < _ref1; x = _k += 1) {
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
    Perlin.composeOctaves = function(octaves, opts) {
      var amp, ampScale, height, i, octaveScale, result, v, width, x, y, _i, _j, _k, _ref, _ref1;
      _ref = octaves[0], width = _ref.width, height = _ref.height;
      result = Perlin.floatArray(width * height);
      ampScale = (opts.amp - 1) / (Math.pow(opts.amp, octaves.length + 1) - opts.amp);
      for (i = _i = 0, _ref1 = octaves.length; _i < _ref1; i = _i += 1) {
        octaveScale = Math.pow(0.5, i);
        amp = Math.pow(opts.amp, octaves.length - i);
        for (y = _j = 0; _j < height; y = _j += 1) {
          for (x = _k = 0; _k < width; x = _k += 1) {
            v = Perlin.interpolateOctave(octaves[i], x * octaveScale, y * octaveScale);
            result[y * width + x] += v * amp * ampScale;
          }
        }
      }
      return result;
    };
    Perlin.interpolateOctave = function(octave, x, y) {
      var get, interpolate, xFrac, xInt, yFrac, yInt;
      xInt = Math.floor(x);
      yInt = Math.floor(y);
      xFrac = x - xInt;
      yFrac = y - yInt;
      interpolate = function(a, b, d) {
        return a * (1 - d) + b * d;
      };
      get = function(x, y) {
        return octave.array[y * octave.width + x];
      };
      return interpolate(interpolate(get(xInt, yInt), get(xInt, yInt + 1), yFrac), interpolate(get(xInt + 1, yInt), get(xInt + 1, yInt + 1), yFrac), xFrac);
    };
    return Perlin;
  });

}).call(this);
