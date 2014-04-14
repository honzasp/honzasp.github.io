require.config
  baseUrl: "lib"
  paths:
    jquery: "../vendor/jquery"

require ["jquery", "menu"], ($, Menu) ->
  Menu($("#krt"))
