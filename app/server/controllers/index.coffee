list = require("./#{key}") for key in ['home']

use = (app) ->
  controller.use(app) for controller in list

module.exports = {use, list}
