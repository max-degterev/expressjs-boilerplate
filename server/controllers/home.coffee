Controller = require('../base/controller')


class Home extends Controller
  default: (req, res) -> res.render('index', __html__: 'default')
  error404: (req, res) -> res.status(404).render('index', __html__: '404')

  attachRoutes: ->
    @get('/', @default)
    @get('*', @error404)

module.exports = new Home()
