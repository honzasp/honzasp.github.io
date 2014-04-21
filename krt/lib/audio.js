// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  define(["require"], function(require) {
    var Audio;
    Audio = {};
    Audio.SOUNDS_URL = require.toUrl("../sound");
    Audio.SOUNDS = {
      "boom_autocannon": ["boom_autocannon_1.wav"],
      "boom_huge_cannon": ["boom_huge_cannon_1.wav"],
      "boom_mining_gun": ["boom_mining_gun_1.wav"],
      "boom_tank": ["boom_tank_1.wav"],
      "get_energy": ["get_energy_1.wav"],
      "get_mass": ["get_mass_1.wav"],
      "hit_concrete": ["hit_concrete_1.wav"],
      "hit_metal": ["hit_metal_1.wav", "hit_metal_2.wav"],
      "hit_rock": ["hit_rock_1.wav", "hit_rock_2.wav"],
      "hit_tank": ["hit_tank_1.wav"],
      "hum_tank": ["hum_tank_1.wav"],
      "shoot_autocannon": ["shoot_autocannon_1.wav"],
      "shoot_emergency_gun": ["shoot_emergency_gun_1.wav"],
      "shoot_huge_cannon": ["shoot_huge_cannon_1.wav"],
      "shoot_machine_gun": ["shoot_machine_gun_1.wav"],
      "shoot_mining_gun": ["shoot_mining_gun_1.wav"]
    };
    Audio.LOAD_TIMEOUT = 20;
    Audio.MIN_GAIN = 0.05;
    Audio.supported = function() {
      return (window.AudioContext != null) || (window.webkitAudioContext != null);
    };
    Audio.init = function(settings, callback) {
      var buffers, callbackCalled, ctx, error, ready, soundFile, soundName, timeout, _fn, _i, _len, _ref;
      if (settings.enableAudio && Audio.supported()) {
        ctx = new (window.AudioContext || window.webkitAudioContext)();
        buffers = {};
        callbackCalled = false;
        ready = function() {
          var audio, soundFiles, soundName, soundsGainNode, _ref;
          if (callbackCalled) {
            return;
          }
          _ref = Audio.SOUNDS;
          for (soundName in _ref) {
            soundFiles = _ref[soundName];
            if (!(buffers[soundName].length >= soundFiles.length)) {
              return;
            }
          }
          soundsGainNode = ctx.createGainNode();
          soundsGainNode.gain.value = settings.soundsGain;
          soundsGainNode.connect(ctx.destination);
          audio = {
            ctx: ctx,
            buffers: buffers,
            soundsGainNode: soundsGainNode
          };
          callbackCalled = true;
          return callback(audio);
        };
        error = function(err) {
          console.log("error initializing audio", err);
          if (!callbackCalled) {
            callbackCalled = true;
            return callback(void 0);
          }
        };
        timeout = function() {
          if (!callbackCalled) {
            return error("timeout");
          }
        };
        setTimeout(timeout, Audio.LOAD_TIMEOUT * 1000);
        for (soundName in Audio.SOUNDS) {
          buffers[soundName] = [];
          _ref = Audio.SOUNDS[soundName];
          _fn = function(soundName, soundFile) {
            var onError, onLoaded, url;
            onLoaded = function(buf) {
              buffers[soundName].push(buf);
              return ready();
            };
            onError = function(err) {
              return error(err);
            };
            url = "" + Audio.SOUNDS_URL + "/" + soundFile;
            return Audio.init.loadSound(ctx, url, onLoaded, onError);
          };
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            soundFile = _ref[_i];
            _fn(soundName, soundFile);
          }
        }
      } else {
        callback(void 0);
      }
      return void 0;
    };
    Audio.init.loadSound = function(ctx, url, onLoaded, onError) {
      var req;
      req = new XMLHttpRequest();
      req.open("GET", url, true);
      req.responseType = "arraybuffer";
      req.onload = function() {
        return ctx.decodeAudioData(req.response, onLoaded, onError);
      };
      req.onerror = onError;
      return req.send();
    };
    Audio.deinit = function(game) {
      if (game.audio == null) {
        return;
      }
      return game.audio.soundsGainNode.disconnect();
    };
    Audio.currentTime = function(game) {
      return game.audio.ctx.currentTime;
    };
    Audio.sound = function(game, soundName, gain) {
      var gainNode, sourceNode;
      if (gain == null) {
        gain = 1;
      }
      if (game.audio == null) {
        return;
      }
      if (gain < Audio.MIN_GAIN) {
        return;
      }
      sourceNode = Audio.createSoundSource(game, soundName);
      gainNode = Audio.addGain(game, sourceNode);
      gainNode.gain.value = gain;
      gainNode.connect(game.audio.soundsGainNode);
      return sourceNode.start(0);
    };
    Audio.createHum = function(game, soundName) {
      var gainNode, sourceNode;
      if (game.audio == null) {
        return;
      }
      sourceNode = Audio.createSoundSource(game, soundName);
      sourceNode.loop = true;
      gainNode = Audio.addGain(game, sourceNode);
      gainNode.gain.value = 0;
      gainNode.connect(game.audio.soundsGainNode);
      sourceNode.start(Math.random() * sourceNode.duration);
      return {
        sourceNode: sourceNode,
        gainNode: gainNode
      };
    };
    Audio.createSoundSource = function(game, soundName) {
      var buffer, buffers, sourceNode;
      buffers = game.audio.buffers[soundName];
      buffer = buffers[Math.floor(Math.random() * buffers.length)];
      sourceNode = game.audio.ctx.createBufferSource();
      sourceNode.buffer = buffer;
      return sourceNode;
    };
    Audio.addGain = function(game, node) {
      var gainNode;
      gainNode = game.audio.ctx.createGainNode();
      node.connect(gainNode);
      return gainNode;
    };
    return Audio;
  });

}).call(this);
