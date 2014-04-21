"use strict"
self.onmessage = (evt) ->
  importScripts("../vendor/require.js")
  require.config
    baseUrl: "./"

  require ["map_gen"], (MapGen) ->
    map = MapGen.gen(evt.data)
    self.postMessage(map, [map.ary.buffer])
    self.close()
