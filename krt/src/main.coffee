require.config
  baseUrl: "lib"
  paths:
    jquery: "../vendor/jquery"

require ["jquery", "menu"], ($, Menu) ->
  $.noConflict(true)
  Menu.init($("#krt"))
