// Generated by CoffeeScript 1.6.3
(function() {
  define([], function() {
    var Map;
    Map = {};
    Map.init = function(width, height) {
      var ary, i, _i, _ref;
      if (typeof Uint8Array !== "undefined" && Uint8Array !== null) {
        ary = new Uint8Array(width * height);
      } else {
        ary = new Array(width * height);
        for (i = _i = 0, _ref = width * height; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          ary[i] = Map.EMPTY;
        }
      }
      return {
        ary: ary,
        width: width,
        height: height
      };
    };
    Map.EMPTY = 0;
    Map.ROCK = 1;
    Map.CONCRETE = 2;
    Map.STEEL = 3;
    Map.get = function(map, x, y) {
      if (!Map.contains(map, x, y)) {
        throw new Error("position out of map");
      }
      return map.ary[x * map.height + y];
    };
    Map.set = function(map, x, y, val) {
      if (!Map.contains(map, x, y)) {
        throw new Error("position out of map");
      }
      return map.ary[x * map.height + y] = val;
    };
    Map.contains = function(map, x, y) {
      return x >= 0 && x < map.width && y >= 0 && y < map.height;
    };
    return Map;
  });

}).call(this);
