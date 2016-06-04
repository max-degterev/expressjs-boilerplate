winston = require('winston')
app = require('express')()
config = require('config')

preRouteMiddleware = ->
  app.use(require('./middleware/domain')())
  app.use(require('./middleware/locals')())

  app.use(require('morgan')(if config.debug then 'dev' else 'combined'))

  # Static middleware is not needed in production, but still loaded for debug purposes
  if config.sandbox
    app.use(require('serve-favicon')(__dirname + '/../public/favicon.ico'))
    app.use(require('serve-static')(__dirname + '/../public', redirect: false))

  app.use(require('connect-livereload')()) if config.debug

  # This middleware has to go last because it ends requests
  app.use(require('./middleware/react')()) if config.server.prerender

postRouteMiddleware = ->
  app.use(require('errorhandler')(dumpExceptions: true, showStack: true)) if config.debug


startListening = ->
  host = process.env.HOST or config.server.host
  port = parseInt(process.env.PORT, 10) or config.server.port or 3000
  message = "Server listening on http://#{host or 'localhost'}:#{port}"

  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', port)
  app.set('views', "#{__dirname}/../templates")
  app.set('view engine', 'pug')
  app.set('json spaces', 2) if config.debug

  preRouteMiddleware()
  require('./controllers')(app)
  postRouteMiddleware()

  if host
    app.listen(port, host, -> winston.info("#{message} (bound to host: #{host})"))
  else
    app.listen(port, -> winston.info(message))

module.exports = startListening
