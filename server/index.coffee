winston = require('winston')
app = require('express')()

config = require('config')

preRouteMiddleware = ->
  app.use(require('./middleware/domain')())
  app.use(require('./middleware/locals')())

  app.use(require('morgan')(if config.debug then 'dev' else 'combined'))

  app.use(require('serve-favicon')(__dirname + '/../public/favicon.ico'))
  app.use(require('serve-static')(__dirname + '/../public', redirect: false))

  app.use(require('./middleware/react')())

  app.use(require('connect-livereload')()) if config.debug

postRouteMiddleware = ->
  app.use(require('errorhandler')(dumpExceptions: true, showStack: true)) if config.debug

module.exports = ->
  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', config.server.port)
  app.set('views', "#{__dirname}/../templates")
  app.set('view engine', 'jade')
  app.set('json spaces', 2) if config.debug

  preRouteMiddleware()
  require('./controllers')(app)
  postRouteMiddleware()

  serverMessage = "Server listening on http://#{config.server.host or 'localhost'}:#{config.server.port}"

  if config.server.host
    app.listen(config.server.port, config.server.host, ->
      winston.info("#{serverMessage} (bound to host: #{config.server.host})")
    )
  else
    app.listen(config.server.port, -> winston.info(serverMessage))
