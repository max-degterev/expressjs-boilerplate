config = require('config')

class Server
  logPrefix: "[app.server]:"
  log: log

  # handle404: (req, res, next)->
  #   res.status(404)
  #   res.render('error')

  router: ->
    @app.get '/', (req, res)-> res.render('layout')

  use: (@app)->
    @router()

    # 404 handler
    # @app.use(@handle404)

    @log('initialized')

module.exports = new Server()
