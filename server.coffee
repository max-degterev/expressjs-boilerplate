#=========================================================================================
# DEPENDENCIES & CONSTANTS
#=========================================================================================
helpers = require('./app/javascripts/shared/helpers')
log = helpers.log

cluster = require('cluster')
config = require('config')
app = require('express')()


#=========================================================================================
# FORKING
#=========================================================================================
if cluster.isMaster
  for i in [1..config.workers]
    log("Starting worker #{i}")
    cluster.fork()

  cluster.on 'exit', (worker, code, signal) ->
    log("Worker #{worker.process.pid} died")

    if config.debug
      process.exit()
    else
      cluster.fork()

else


#=========================================================================================
# INIT DB CONNECTION AND INSTANTIATE SERVER
#=========================================================================================
  server = require('./app/javascripts/server')
  assetsHashMap = require('./public/assets/hashmap.json') unless config.debug


#=========================================================================================
# TEMPLATE GLOBABS
#=========================================================================================
  generateTemplateGlobals = ->
    app.locals.pretty = config.debug
    app.locals.helpers = helpers
    app.locals.env = process.env.NODE_ENV

    env = {}
    env[key] = config[key] for key in ['hostname', 'base_url', 'debug', 'ga_id']
    env.version = require('./package').version

    app.locals.client_env = env


#=========================================================================================
# MIDDLEWARE
#=========================================================================================
  normalizeUrl = (req, res, next) ->
    try
      decodeURIComponent(req.originalUrl)
    catch
      url = '/'
      log("malformed URL, redirecting to #{url}")
      return res.redirect(301, url)

    [href, qs...] = req.originalUrl.split('?')

    if qs.length > 1 # should be 1?2, [2].length = 1
      url = href + '?' + qs.join('&')
      log("malformed URL, redirecting to #{url}")
      return res.redirect(301, url)

    next()

  _getAsset = (name)->
    if config.debug
      "/assets/#{name}"
    else
      ext = name.split('.').pop()
      baseName = name.replace('.' + ext, '')
      hash = assetsHashMap[name]
      "/assets/#{baseName}.min.#{hash}.#{ext}"

  gruntAssets = (req, res, next)->
    req.app.locals.getAsset = _getAsset
    next()

  preRouteMiddleware = ->
    morgan = require('morgan')

    if config.debug
      app.use(morgan('dev'))
    else
      app.use(morgan('default'))

    app.use(normalizeUrl)

    app.use(require('serve-favicon')(__dirname + '/public/favicon.ico'))
    app.use(require('serve-static')(__dirname + '/public', redirect: false))

    app.use(gruntAssets)

  postRouteMiddleware = ->
    if config.debug
      app.use(require('errorhandler')(dumpExceptions: true, showStack: true))
    else
      app.use(require('compression')())


#=========================================================================================
# START LISTENING FOR CONNECTIONS
#=========================================================================================
  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', config.port)
  app.set('views', __dirname + '/app/templates/server')
  app.set('view engine', 'jade')
  app.set('json spaces', 2) if config.debug

  generateTemplateGlobals()

  preRouteMiddleware()
  server.use(app) # Fire up the server, all the routes go here
  postRouteMiddleware()

  if config.debug
    app.listen(app.get('port'), -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (unbound)"))
  else
    if config.ip
      app.listen(app.get('port'), config.ip, -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (bound to ip: #{config.ip})"))
    else
      app.listen(app.get('port'), -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (unbound)"))
