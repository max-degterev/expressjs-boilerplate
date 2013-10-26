helpers = require('../shared/helpers')
config = require('config')

class Server
  logPrefix: '[app.server]:'
  log: helpers.log

  handle404: (req, res, next)->
    res.status(404)
    res.render('pages/404')

  router: ->
    @app.get('/', (req, res)-> res.render('layout'))

  use: (@app)->
    @router()

    # 404 handler
    @app.use(@handle404)

    @log('initialized')

module.exports = new Server()
