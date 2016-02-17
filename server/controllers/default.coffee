Controller = require('../base/controller')


class Default extends Controller
  default: (req, res) -> res.render('index')

  attachRoutes: ->
    @get('*', @default)

module.exports = new Default()
