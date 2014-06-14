Controller = require('./base/controller')


module.exports = class Server extends Controller
  logPrefix: '[app.server]:'

  default: (req, res)-> res.render('layout')
  error404: (req, res)-> res.status(404).render('prerender/error')

  router: ->
    @get('/', @default)
    @get('*', @error404)
