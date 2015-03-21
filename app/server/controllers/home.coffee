Controller = require('../base/controller')

class Home extends Controller
  logPrefix: '[app.server/controllers.home]:'

  default: (req, res)-> res.render('layout')
  error404: (req, res)-> res.status(404).render('server/error')

  router: ->
    @get('/', @default)
    @get('*', @error404)

module.exports = new Home
