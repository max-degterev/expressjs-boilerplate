list = for key in ['home']
  require("./#{key}")

use = (app) ->
  controller.use(app) for controller in list

module.exports = {use, list}
