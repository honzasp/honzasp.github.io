// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  define(["jquery", "menu"], function($, Menu) {
    var Config;
    Config = {};
    Config.buildConfig = function(menu) {
      var $config;
      $config = $("<div class='config'>\n  <div class='left'></div>\n  <div class='right'></div>\n</div>");
      $config.find(".left").append([Config.buildMode(menu), Config.buildMap(menu)]);
      $config.find(".right").append([Config.buildGfx(menu), Config.buildAudio(menu)]);
      return $config;
    };
    Config.buildMode = function(menu) {
      var $mode;
      $mode = $("<fieldset class='mode'>\n  <legend>mode</legend>\n  <p>\n    <label><input type='radio' name='mode' value='time'> <span>time:</span></label>\n    <input type='number' name='time' min='1' step='1' class='mode-depends mode-time'>\n  </p>\n  <p>\n    <label><input type='radio' name='mode' value='lives'> <span>lives:</span></label>\n    <input type='number' name='lives' min='1' step='1' class='mode-depends mode-lives'>\n  </p>\n  <p>\n    <label><input type='radio' name='mode' value='hits'> <span>hits:</span></label>\n    <input type='number' name='hits' min='1' step='1' class='mode-depends mode-hits'>\n  </p>\n</fieldset>");
      $mode.find("input[name=time]").val(menu.state.modes.time).change(function() {
        menu.state.modes.time = Menu.valInt(this, 1);
        return Menu.save(menu);
      });
      $mode.find("input[name=lives]").val(menu.state.modes.lives).change(function() {
        menu.state.modes.lives = Menu.valInt(this, 1);
        return Menu.save(menu);
      });
      $mode.find("input[name=hits]").val(menu.state.modes.hits).change(function() {
        menu.state.modes.hits = Menu.valInt(this, 1);
        return Menu.save(menu);
      });
      $mode.find("input[name=mode]").change(function() {
        menu.state.modes.mode = $mode.find("input[name=mode]:checked").val();
        $mode.trigger("changed-mode.krt");
        return Menu.save(menu);
      });
      $mode.on("changed-mode.krt", function() {
        $mode.find("input.mode-depends").attr("disabled", true);
        return $mode.find("input.mode-" + menu.state.modes.mode).removeAttr("disabled");
      });
      $mode.find("input[name=mode][value=" + menu.state.modes.mode + "]").attr("checked", true);
      $mode.trigger("changed-mode.krt");
      return $mode;
    };
    Config.buildMap = function(menu) {
      var $map;
      $map = $("<fieldset class='map'>\n  <legend>map</legend>\n  <p>\n    <label><span>width:</span> \n    <input type='number' name='map-width' min='50' step='1'></label>\n  </p>\n  <p>\n    <label><span>height:</span> \n    <input type='number' name='map-height' min='50' step='1'></label>\n  </p>\n  <p>\n    <label><span>noisiness:</span>\n    <input type='number' name='map-noisiness' min='1' max='99'></label>\n  </p>\n  <p>\n    <label><span>emptiness:</span> \n    <input type='number' name='map-emptiness' min='1' max='99'></label>\n  </p>\n  <p>\n    <label><span>seed:</span>\n    <input type='text' name='map-seed'></label>\n  </p>\n</fieldset>");
      $map.find("input[name=map-width]").val(menu.state.mapWidth).change(function() {
        menu.state.mapWidth = Menu.valInt(this, 50);
        return Menu.save(menu);
      });
      $map.find("input[name=map-height]").val(menu.state.mapHeight).change(function() {
        menu.state.mapHeight = Menu.valInt(this, 50);
        return Menu.save(menu);
      });
      $map.find("input[name=map-noisiness]").val(menu.state.mapNoisiness).change(function() {
        menu.state.mapNoisiness = Menu.valFloat(this, 1, 99);
        return Menu.save(menu);
      });
      $map.find("input[name=map-emptiness]").val(menu.state.mapEmptiness).change(function() {
        menu.state.mapEmptiness = Menu.valFloat(this, 1, 99);
        return Menu.save(menu);
      });
      $map.find("input[name=map-seed]").val(menu.state.mapSeed).change(function() {
        menu.state.mapSeed = $(this).val();
        return Menu.save(menu);
      });
      return $map;
    };
    Config.buildGfx = function(menu) {
      var $gfx;
      $gfx = $("<fieldset class='gfx'>\n  <legend>gfx</legend>\n  <p>\n    <label><span>frames per second:</span> \n    <input type='number' name='fps' value=''></label>\n  </p>\n  <p>\n    <label><span>head-up display:</span>\n    <input type='checkbox' name='hud'></label>\n  </p>\n  <p>\n    <label><span>name tags:</span>\n    <input type='checkbox' name='name-tags'></label>\n  </p>\n  <p>\n    <label><span>rotate viewport:</span>\n    <input type='checkbox' name='rotate-viewport'></label>\n  </p>\n</fieldset>");
      $gfx.find("input[name=fps]").val(menu.state.fps).change(function() {
        menu.state.fps = Menu.valFloat(this, 1, 200);
        return Menu.save(menu);
      });
      $gfx.find("input[name=hud]").attr("checked", menu.state.hud).change(function() {
        menu.state.hud = $(this).is(":checked");
        return Menu.save(menu);
      });
      $gfx.find("input[name=name-tags]").attr("checked", menu.state.nameTags).change(function() {
        menu.state.nameTags = $(this).is(":checked");
        return Menu.save(menu);
      });
      $gfx.find("input[name=rotate-viewport]").attr("checked", menu.state.rotateViewport).change(function() {
        menu.state.rotateViewport = $(this).is(":checked");
        return Menu.save(menu);
      });
      return $gfx;
    };
    Config.buildAudio = function(menu) {
      var $audio;
      $audio = $("<fieldset class='audio'>\n  <legend>audio</legend>\n  <p>\n    <label><span>audio enabled:</span>\n    <input type='checkbox' name='audio-enabled'></label>\n  </p>\n  <p>\n    <label><span>sounds volume:</span>\n    <input type='number' min='0' max='100' name='sounds-volume'></label>\n  </p>\n</fieldset>");
      $audio.find("input[name=audio-enabled]").attr("checked", menu.state.audioEnabled).change(function() {
        menu.state.audioEnabled = $(this).is(":checked");
        Menu.save(menu);
        return $audio.trigger("audio-changed.krt");
      });
      $audio.find("input[name=sounds-volume]").val(menu.state.soundsVolume).change(function() {
        menu.state.soundsVolume = Menu.valFloat(this, 0, 100);
        return Menu.save(menu);
      });
      $audio.on("audio-changed.krt", function() {
        return $audio.find("input[name=sounds-volume]").attr("disabled", !menu.state.audioEnabled);
      });
      $audio.trigger("audio-changed.krt");
      return $audio;
    };
    return Config;
  });

}).call(this);
