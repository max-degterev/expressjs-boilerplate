CONTROLLERS = [
  'default'
]


module.exports = (app) ->
  for name in CONTROLLERS
    controller = require("./#{name}")
    controller.use(app)
