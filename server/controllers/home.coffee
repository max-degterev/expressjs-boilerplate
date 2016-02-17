Controller = require('../base/controller')


class Home extends Controller
  home: (req, res) -> res.render('index', content: 'home')
  api: (req, res) -> res.send({ status: 'ok' })
  error404: (req, res) -> res.status(404).send({ error: 'Endpoint doesn\'t exist' })

  attachRoutes: ->
    @get('/', @home)
    @get('/api.json', @api)
    @get('/api/*', @error404)

module.exports = new Home()
