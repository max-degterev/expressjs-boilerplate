Controller = require('../base/controller')


class Home extends Controller
  home: (req, res) -> res.render('index', __html__: 'home')
  error404: (req, res) -> res.status(404).render('index', __html__: '404')

  attachRoutes: ->
    @get('/', @home)
    @get('*', @error404)

module.exports = new Home()
