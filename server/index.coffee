createDomain = require('domain').create
winston = require('winston')

_ = require('lodash')
app = require('express')()
serialize = require('serialize-javascript')

# environment = require('../lib/environment')
config = require('../config')


generateTemplateGlobals = ->
  globals =
    __appConfig__: serialize(config.client)
    __getAsset__: require('./lib/assets')

  _.assignIn(app.locals, globals)

domainify = (req, res, next) ->
  domain = createDomain()
  domain.add(req)
  domain.add(res)
  domain.run(next)
  domain.on('error', next)

preRouteMiddleware = ->
  app.use(domainify)
  app.use(require('morgan')(if config.debug then 'dev' else 'combined'))

  app.use(require('serve-favicon')(__dirname + '/../public/favicon.ico'))
  app.use(require('serve-static')(__dirname + '/../public', redirect: false))

  # app.use(environment.middleware)

postRouteMiddleware = ->
  app.use(require('errorhandler')(dumpExceptions: true, showStack: true)) if config.debug

module.exports = ->
  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', config.server.port)
  # app.set('views', "#{__dirname}/../templates")
  # app.set('view engine', 'jade')
  app.set('json spaces', 2) if config.debug

  generateTemplateGlobals()

  preRouteMiddleware()
  require('./controllers').use(app)
  postRouteMiddleware()

  serverMessage = "Server listening on http://#{config.server.host}:#{config.server.port}"

  if config.server.host
    app.listen(config.server.port, config.server.host, ->
      winston.info("#{serverMessage} (bound to host: #{config.server.host})")
    )
  else
    app.listen(config.server.port, -> winston.info(serverMessage))
