Controller = require('../base/controller')


class Home extends Controller
  default: (req, res) -> res.send('Default')
  error404: (req, res) -> res.status(404).send('Error 404')

  attachRoutes: ->
    @get('/', @default)
    @get('*', @error404)

module.exports = new Home()
