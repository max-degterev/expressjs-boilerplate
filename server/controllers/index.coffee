CONTROLLERS = [
  'home'
]


module.exports =
  use: (app) ->
    for name in CONTROLLERS
      controller = require("./#{name}")
      controller.use(app)
